/* Yaks in every direction:
 * 1. Goal is to build glibc successfully from within default-build.
 * 2. To build glibc, need to run some glibc-owned gawk scripts.
 * 3. At least one of these scripts relies on the gawk system()
 *    builtin.
 * 4. It turns out this is implemented on top of glibc's system()
 *    function.
 * 5. glibc (as required by POSIX) invokes /bin/sh directly,
 *    baking in that path.
 *
 * To get a version of glibc to build, we require an implementation
 * of system() that can refer to nix-store-owned bash instead of /bin/sh.
 *
 * We only require a version of system() sufficient to prepare
 * nix nix bootstrap gawk version with which we can build glibc.
 * For example we don't need nix threadsafe implementation
 * (since glibc does not support nix parallel build in the first place).
 *
 * We'll attempt such primitive implementation below.
 *
 * We'll also need an alternative implementation of popen(),
 * see nxfs_popen.c
 *
 */

#include <signal.h>
#include <unistd.h>
#include <spawn.h>

#define SHELL_PATH "@bash_path@"
#define SHELL_NAME "bash"

int nxfs_system(const char* line)
{
    struct sigaction sa;
    sigset_t reset_sigmask;

    /* init */
    sa.sa_handler = SIG_IGN;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);

    struct sigaction sa_intr;
    {
        /* ignore INT -- noop signal handler*/
        sigaction(SIGINT, &sa, &sa_intr);
    }

    struct sigaction sa_quit;
    {
        /* ignore QUIT -- noop signal handler */
        sigaction(SIGQUIT, &sa, &sa_quit);
    }

    /* block SIGCHLD while body of nxfs_system() runs */
    sigset_t original_sigmask;
    {
        sigaddset(&sa.sa_mask, SIGCHLD);
        sigprocmask(SIG_BLOCK, &sa.sa_mask, &original_sigmask);
    }

    sigemptyset(&reset_sigmask);
    if (sa_intr.sa_handler != SIG_IGN)
        sigaddset(&reset_sigmask, SIGINT);
    if (sa_quit.sa_handler != SIG_IGN)
        sigaddset(&reset_sigmask, SIGQUIT);

    posix_spawnattr_t spawn_attr;
    {
        posix_spawnattr_init(&spawn_attr);
        /* signal mask in child process */
        posix_spawnattr_setsigmask(&spawn_attr, &original_sigmask);
        /* force default signal handling for INT,QUIT in child process */
        posix_spawnattr_setsigdefault(&spawn_attr, &reset_sigmask);
        posix_spawnattr_setflags(&spawn_attr, POSIX_SPAWN_SETSIGMASK|POSIX_SPAWN_SETSIGDEF);
    }

    const char* args[] = { SHELL_NAME, "-c", "--", line, NULL };

    int pid = 0;
    int retval = posix_spawn(&pid, SHELL_PATH, 0, &spawn_attr,
                             (char * const*)args, environ);
    int status = 0;

    posix_spawnattr_destroy(&spawn_attr);

    if (retval == 0) {
        if (TEMP_FAILURE_RETRY(waitpid(pid, &status, 0)) != pid)
            status = -1;
    } else {
        status = W_EXITCODE(127, 0);
    }

    sigaction(SIGINT, &sa_intr, NULL);
    sigaction(SIGQUIT, &sa_quit, NULL);
    sigprocmask(SIG_SETMASK, &original_sigmask, NULL);

    if (retval != 0)
        errno = retval;

    return status;
}
