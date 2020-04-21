FROM alvrme/alpine-android:android-29
LABEL author="artur@barichello.me, bemyak@gmail.com"
ENV GODOT_VERSION "3.2"

COPY . .

RUN ls

RUN apk add python3 py3-openssl zip \
    && wget -q https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && wget -q https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
    && rm -f Godot_v${GODOT_VERSION}-stable_export_templates.tpz Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    # Generate keystore
    && keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore /opt/debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
    # First initialization
    && godot -q \
    # Delete default settings if they exist
    && sed -i '/export\/android\/adb/d' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/export\/android\/jarsigner/d' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/export\/android\/debug_keystore/d' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/export\/android\/debug_keystore_user/d' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/export\/android\/debug_keystore_pass/d' /root/.config/godot/editor_settings-3.tres \
    # Set new settings
    && sed -i '/\[resource\]/a export\/android\/adb = "/opt/sdk/platform-tools/adb"' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/\[resource\]/a export\/android\/jarsigner = "/opt/java/openjdk/bin/jarsigner"' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/\[resource\]/a export\/android\/debug_keystore = "/opt/debug.keystore"' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/\[resource\]/a export\/android\/debug_user = "androiddebugkey"' /root/.config/godot/editor_settings-3.tres \
    && sed -i '/\[resource\]/a export\/android\/debug_pass = "android"' /root/.config/godot/editor_settings-3.tres