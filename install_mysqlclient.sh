#!/usr/bin/env bash

# Debugging and installation script for mysqlclient

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Find system paths
find_paths() {
    # MySQL library
    MYSQL_LIB_PATH=$(find /nix/store -name "libmysqlclient.so" | head -n 1)
    MYSQL_LIB_DIR=$(dirname "$MYSQL_LIB_PATH")
    log "MySQL Library Path: $MYSQL_LIB_PATH"

    # Python include path
    PYTHON_INCLUDE_PATH=$(find /nix/store -path "*/python3-3.11*" -name "Python.h" | head -n 1)
    PYTHON_INCLUDE_DIR=$(dirname "$PYTHON_INCLUDE_PATH")
    log "Python Include Path: $PYTHON_INCLUDE_PATH"

    # GCC library path
    GCC_LIB_PATH=$(find /nix/store -name "libgcc_s.so" | head -n 1)
    GCC_LIB_DIR=$(dirname "$GCC_LIB_PATH")
    log "GCC Library Path: $GCC_LIB_PATH"

    # Binutils path (for crti.o)
    BINUTILS_PATH=$(find /nix/store -name "crti.o" | head -n 1)
    log "Binutils Path: $BINUTILS_PATH"
}

# Installation method
install_mysqlclient() {
    log "Attempting to install mysqlclient..."

    # Find paths
    find_paths

    # Prepare compilation flags
    export CFLAGS="-I${MYSQL_LIB_DIR}/../include/mysql -I$PYTHON_INCLUDE_DIR"
    export LDFLAGS="-L$MYSQL_LIB_DIR -L$GCC_LIB_DIR"
    export LD_LIBRARY_PATH="$MYSQL_LIB_DIR:$GCC_LIB_DIR:$LD_LIBRARY_PATH"

    # Additional flags to help with linking
    export LIBRARY_PATH="$MYSQL_LIB_DIR:$GCC_LIB_DIR:$LIBRARY_PATH"

    log "CFLAGS: $CFLAGS"
    log "LDFLAGS: $LDFLAGS"
    log "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

    # Try installation methods
    pip install --upgrade pip setuptools wheel

    # Method 1: Standard installation with verbose output
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    pip install mysqlclient --no-binary mysqlclient --verbose && return 0

    # Method 2: Alternative installation with additional flags
    CFLAGS="$CFLAGS -I/nix/store/*/include" \
    LDFLAGS="$LDFLAGS -L/nix/store/*/lib" \
    pip install mysqlclient --no-binary mysqlclient --verbose && return 0

    # Fallback: pymysql
    log "Falling back to pymysql"
    pip install pymysql && return 0

    log "ERROR: Failed to install MySQL client library"
    return 1
}

# Main script
main() {
    # Ensure virtual environment is activated
    if [ -z "$VIRTUAL_ENV" ]; then
        log "ERROR: Activate your virtual environment first!"
        exit 1
    fi

    # Run installation
    install_mysqlclient
}

# Run the main function
main