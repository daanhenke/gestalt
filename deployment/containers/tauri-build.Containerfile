FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    # Linux desktop dependencies for Tauri
    libwebkit2gtk-4.1-dev \
    libappindicator3-dev \
    librsvg2-dev \
    # Additional system libraries
    libssl-dev \
    libgtk-3-dev \
    libsoup-3.0-dev \
    libjavascriptcoregtk-4.1-dev \
    # Windows cross-compilation dependencies
    mingw-w64 \
    # Android dependencies
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    # Java for Android builds
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup default stable

# Add Rust targets for cross-compilation
RUN rustup target add x86_64-pc-windows-gnu
RUN rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# Install Node.js 20 LTS via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm

# Install Android SDK and NDK
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV ANDROID_NDK_VERSION=26.1.10909125
ENV ANDROID_NDK_ROOT=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION

# Create Android SDK directory
RUN mkdir -p $ANDROID_HOME/cmdline-tools

# Download and install Android command line tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# Add Android SDK tools to PATH
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools:$PATH"

# Accept Android SDK licenses and install required packages
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-33" "platforms;android-34" "build-tools;34.0.0" "ndk;$ANDROID_NDK_VERSION"

# Install Tauri CLI
RUN cargo install tauri-cli --version "^2.0" --locked

# Install cargo-ndk for Android builds
RUN cargo install cargo-ndk

# Set up Windows cross-compilation linker
ENV CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
ENV CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
ENV AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc

# Create a working directory
WORKDIR /workspace

# Install additional tools that might be needed
RUN apt-get update && apt-get install -y \
    file \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN echo "=== Tool Versions ===" \
    && node --version \
    && pnpm --version \
    && cargo --version \
    && rustc --version \
    && java -version \
    && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --version \
    && echo "ANDROID_HOME: $ANDROID_HOME" \
    && echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT" \
    && ls -la $ANDROID_NDK_ROOT || echo "NDK not found"
