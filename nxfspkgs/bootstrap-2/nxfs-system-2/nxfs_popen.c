/*
 * 3. At least one of these scripts relies on gawk like:
 *       printf "%s", xyz | sort -u
 *    which fails with "no such file or directory"
 *    if we try to build glibc with vanilla gawk.
 * 4. This is because gawk relies on glibc popen(),
 *    which uses execve(), which ignores PATH.
 *    We can expect this to break under nix-build,
 *    because sort will be somewhere in nix-store.
 * 5. Workaround this by providing a function like popen(),
 *    but that calls execlp() instead of execl()
 */

#include <stdio.h>
#include <pid.h>

#define SHELL_PATH "@bash_path@"
#define SHELL_NAME "bash"

/* mirror of glibc _IO_proc_file */
struct nxfs_proc_file {
    FILE file;
    pid_t pid;
    struct nxfs_proc_file* next;
};

/* mode must be "r" or "w" */
FILE *
nxfs_popen (char const* command, char const* mode)
{
    int parent_end;
    int child_end;

    int pipe_fds[2];
    pid_t child_pid;

    if (pipe (pipe_fds) < 0) {
        return NULL;
    }

    if (mode[0] == 'r' && mode[1] == '\0') {
        parent_end = pipe_fds[0];
        child_end = pipe_fds[1];
    } else if (mode[0] == 'w' && mode[1] == '\0') {
        parent_end = pipe_fds[1];
        child_end = pipe_fds[0];
    } else {
        close(pipe_fds[0]);
        close(pipe_fds[1]);
        errno = EINVAL;
        return NULL;
    }
    child_pid = fork();

    if (child_pid == 0) {
        /* control here: we are child process
         *   mode is 'r'
         *     -> pipe direction is child->parent
         *     -> redirect 1=stdout to pipe-to-parent
         *   mode is 'w'
         *     -> pipe direction is parent->child
         *     -> redirect 0=stdin to pipe-from-parent
         */
        int child_std_end = (mode[0] == 'r' ? 1 : 0);

        close(parent_end);
        if (child_end != child_std_end) {
            dup2(child_end, child_std_end);
            close(child_end);
        }

        /* We're supposed to close "all the other open files".
         * Could remedy by scanning /proc/mypid/fd;
         * omitting out of expedience.
         */

        execlp (SHELL_PATH, SHELL_NAME, "-c", command, (char *) 0);

        /* control here iff execlp() fails */
        exit (127);
    }
    close (child_end);
    if (child_pid < 0)
    {
        /* failed to spawn child process */
        close (parent_end);
        return NULL;
    } else {
        /* adopt parent_end */
        FILE* fp = fdopen(parent_end, mode);

        return fp;
    }
}

/* pclose() won't work for a FILE* created by nxfs_popen();
 * believe it's because glibc some secret state,
 * which entangles its implementation of {popen(), pclose()}
 */
int
nxfs_pclose (FILE* fp)
{
    int status = 0;
    pid_t pid = -1;

    // fclose: close given file stream.  flush buffered data
    if (fclose(fp) == EOF) {
        // control here if flush failed (e.g. out of disk)
        return -1;
    }

    while ((pid = wait(&status)) == -1) {
        if (errno != EINTR)
            return -1;
    }

    return status;
}
