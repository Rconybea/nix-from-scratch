#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>

#define SHELL_PATH "@bash_path@"
#define SHELL_NAME "bash"

/* mode must be "r" or "w" */
FILE *
nxfs_popen (char const* command, char const* mode)
{
    fprintf(stderr, "nxfs_popen: enter\n");

    int parent_end;
    int child_end;

    int pipe_fds[2];
    pid_t child_pid;

    if (pipe (pipe_fds) < 0) {
        fprintf(stderr, "nxfs_popen: pipe() failed");
        return NULL;
    }

    fprintf(stderr, "nxfs_popen: pipe_fds[0]=[%d] pipe_fds[1]=[%d]\n", pipe_fds[0], pipe_fds[1]);

    if (mode[0] == 'r' && mode[1] == '\0') {
        parent_end = pipe_fds[0];
        child_end = pipe_fds[1];
    } else if (mode[0] == 'w' && mode[1] == '\0') {
        parent_end = pipe_fds[1];
        child_end = pipe_fds[0];
    } else {
        fprintf(stderr, "nxfs_popen: invalid mode\n");

        close(pipe_fds[0]);
        close(pipe_fds[1]);
        errno = EINVAL;
        return NULL;
    }
    child_pid = fork();

    if (child_pid == 0) {
        fprintf(stderr, "nxfs_popen: child process\n");

        //int child_std_end = (mode[0] == 'r' ? 1 : 0);

        /* control here: we are child process
         *   mode is 'r'
         *     -> desired pipe direction is child->parent
         *     -> redirect 1=stdout in child to pipe-to-parent
         *     child's fd 0 shared with parent = stdin
         *   mode is 'w'
         *     -> desired pipe direction is parent->child
         *     -> redirect 0=stdin in child to pipe-from-parent
         *     child's fd 1 shared with parent = stdout
         */
        if (mode[0] == 'r') {
            /* pipe_fds[0] is output-end of pipe, belongs to parent */
            close(pipe_fds[0]);

            if (child_end != 1) {
                /* redirect child's stdout to write to pipe-to-parent */
                dup2(child_end, 1);
                /* ..and close the original file descriptor */
                close(child_end);
            }
        } else if (mode[0] == 'w') {
            /* pipe_fds[1] is input-end of pipe, belongs to parent */
            close(pipe_fds[1]);

            if (child_end != 0) {
                /* redirect child's stdin to read from pipe-from-parent */
                dup2(child_end, 0);
                /* .. and close the original file descriptor */
                close(child_end);
            }
        }

        /* We're supposed to close "all the other open files".
         * Could remedy by scanning /proc/mypid/fd;
         * omitting out of expedience.
         */

        fprintf(stderr, "about to execlp()\n");
        fprintf(stderr, "  SHELL_PATH=[%s]\n", SHELL_PATH);
        fprintf(stderr, "  SHELL_NAME=[%s]\n", SHELL_NAME);
        fprintf(stderr, "  command=[%s]\n", command);

        execl (SHELL_PATH, SHELL_NAME, "-c", command, (char *) 0);

        fprintf(stderr, "execl failed\n");

        /* control here iff execlp() fails */
        exit (127);
    }

    fprintf(stderr, "nxfs_popen: parent process\n");

    /* control here means we are parent process */

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

int
nxfs_pclose(FILE* fp)
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

int read_test()
{
    FILE* fp = nxfs_popen("ls -l", "r");
    char buffer[1024];

    if (fp == NULL) {
        perror("nxfs_popen");
        return EXIT_FAILURE;
    }

    while (fgets(buffer, sizeof(buffer), fp) != NULL)
        printf("%s", buffer);

    if (nxfs_pclose(fp) == -1) {
        perror("nxfs_pclose");
        return EXIT_FAILURE;
    }

    return 0;
}

int write_test0()
{
    FILE* fp = nxfs_popen("echo hello > foo", "w");

    if (nxfs_pclose(fp) == -1) {
        perror("nxfs_pclose");
        return EXIT_FAILURE;
    }

    return 0;
}

int write_test1()
{
    FILE* fp = nxfs_popen("echo hello", "w");

    if (nxfs_pclose(fp) == -1) {
        perror("nxfs_pclose");
        return EXIT_FAILURE;
    }

    return 0;
}

int write_test2()
{
    FILE* fp = nxfs_popen("@sort_program@ -r", "w");

    if (fp == NULL) {
        perror("nxfs_popen");
        return EXIT_FAILURE;
    }

    /* 1, 2, 3, 4, 5 */
    char* buf[] = { "3\n", "2.0\n", "3.1\n", "99.9\n", "2.0\n", "1.9\n", "1.99\n", "1.91\n", NULL };

    for (int i=0; buf[i] != NULL; ++i) {
        fprintf(stderr, "write buf[%d]=[%s]\n", i, buf[i]);

        fputs(buf[i], fp);
    }

    if (nxfs_pclose(fp) == -1) {
        perror("pclose");
        return EXIT_FAILURE;
    }

    return 0;
}

int main(int argc, char* argv[])
{
    int err = 0;

#ifdef NOT_IN_USE
    err = read_test();
    if (err < 0)
        return err;
#endif

#ifdef NOT_IN_USE
    err = write_test0();
    if (err < 0)
        return err;
#endif

#ifdef NOT_IN_USE
    err = write_test1();
    if (err < 0)
        return err;
#endif

    err = write_test2();
    if (err < 0)
        return err;

    return 0;
}
