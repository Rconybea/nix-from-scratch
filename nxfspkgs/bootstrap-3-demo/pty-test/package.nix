{ stdenv,
  # python :: derivation
  python,
}:

stdenv.mkDerivation {
  name = "pty-test";

  dontUnpack = true;

  unpackPhase = ":";

  buildPhase =
''
    echo "=== PTY Diagnostics ==="

   echo "=== Detailed PTY Debug ==="

    echo "1. Check /dev/ptmx exists:"
    ls -la /dev/ptmx || echo "ls failed"

    echo ""
    echo "2. Check file type:"
    file /dev/ptmx || echo "file command failed"

    echo ""
    echo "3. Check if it's a real device:"
    test -c /dev/ptmx && echo "/dev/ptmx is a character device" || echo "/dev/ptmx is NOT a character device"

    echo ""
    echo "4. Check readlink (is it a symlink?):"
    readlink /dev/ptmx || echo "Not a symlink"

    echo ""
    echo "5. Try to read from it with dd:"
    dd if=/dev/ptmx of=/dev/null bs=1 count=0 2>&1 || echo "dd failed"

    echo ""
    echo "6. Check /proc/self/mountinfo for /dev:"
    cat /proc/self/mountinfo | grep -E '(/dev |/dev/pts |/dev/ptmx)' || echo "No /dev mounts in mountinfo"

    echo ""
    echo "7. Checking /dev/pts/:"
    ls -la /dev/pts/ 2>&1 || echo "Cannot list /dev/pts"

    echo ""
    echo "8. Trying to open /dev/ptmx directly:"
    if [ -w /dev/ptmx ]; then
      echo "/dev/ptmx is writable"
    else
      echo "/dev/ptmx is NOT writable"
    fi

    echo ""
    echo "Current user info:"
    id

    echo ""
    echo "File descriptor test:"
    if exec 99<>/dev/ptmx 2>&1; then
      echo "Successfully opened /dev/ptmx as FD 99"
      echo "Checking slave device:"
      readlink /proc/self/fd/99 || echo "Cannot readlink FD"
    else
      echo "Failed to open /dev/ptmx"
    fi

    echo "=== PTY Test ==="

    # Check proc filesystem
    if [ -r /proc/sys/kernel/pty/max ]; then
      echo "Max PTYs: $(cat /proc/sys/kernel/pty/max)"
      echo "Current PTYs: $(cat /proc/sys/kernel/pty/nr)"
    else
      echo "/proc/sys/kernel/pty/* not readable"
    fi

    echo ""
    echo "Testing PTY allocation with Python..."

    # Use Python's pty module (if available in your bootstrap)
    python3 -c '
import pty
import os
import sys

ptys = []
count = 0
max_attempts = 2000


try:
    for i in range(max_attempts):
        try:
            master, slave = pty.openpty()
            ptys.append((master, slave))
            count += 1
            if (i + 1) % 100 == 0:
                print(f"Allocated {count} PTYs so far...")
        except OSError as e:
            print(f"Failed at PTY #{i+1}: {e}")
            break
finally:
    print(f"\n=== Results ===")
    print(f"Successfully allocated {count} PTYs")
    for master, slave in ptys:
        os.close(master)
        os.close(slave)
'
'';

  installPhase = ''
    mkdir -p $out
    echo "done" > $out/result.txt
  '';

  nativeBuildInputs = [ python ];
}
