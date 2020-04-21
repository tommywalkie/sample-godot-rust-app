FROM ubuntu:cosmic
LABEL author="artur@barichello.me,myoodster@gmail.com"

# Install development and other tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    python \
    python-openssl \
    unzip \
    wget \
    zip \
    curl \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

# Use Godot 3.2
ENV GODOT_VERSION "3.2"

# Download and install Godot Engine (headless) and export templates
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir -v ~/.cache \
    && mkdir -p -v ~/.config/godot \
    && mkdir -p -v ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip
    
# Download and install Android SDK
RUN mkdir -p -v ~/android \
    && cd ~/android \
    && curl -fsSLO "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    && unzip -q sdk-tools-linux-*.zip \
    && rm sdk-tools-linux-*.zip

ENV ANDROID_HOME ~/android

# Download and install SDK tools, accept licences, and create debug.keystore
RUN mkdir -p -v ~/.android
RUN echo "count=0" > ~/.android/repositories.cfg
RUN yes | ~/android/tools/bin/sdkmanager --licenses
RUN yes | ~/android/tools/bin/sdkmanager "tools"
RUN yes | ~/android/tools/bin/sdkmanager "platform-tools"
RUN yes | ~/android/tools/bin/sdkmanager "build-tools;28.0.3"
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    && mv debug.keystore ~/android/debug.keystore
   
# Initialize Godot so it creates editor_settings-3.tres file, then add android export section, since it is missing at first
RUN godot -e -q
RUN echo 'export/android/adb = "/root/android/platform-tools/adb"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore = "/root/android/debug.keystore"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/jarsigner = "/usr/lib/jvm/java-8-openjdk-amd64/bin/jarsigner"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/force_system_user = false' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/timestamping_authority_url = ""' >> ~/.config/godot/editor_settings-3.tres
RUN echo 'export/android/shutdown_adb_on_exit = true' >> ~/.config/godot/editor_settings-3.tres