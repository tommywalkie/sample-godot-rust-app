# Supported platforms

Usually, in order to succesfully build/export signed Rust/GDNative games, some steps may require to pay real money and install/use a few tools :
- Which may be subject to proprietary licenses, like [macOS](https://discussions.apple.com/thread/6135949) and [Xcode](https://www.apple.com/legal/sla/docs/xcode.pdf)
- Which can be tricky to set up, like MSYS2 for Windows
- Which are bloated, like IntelliJ/Android Studio

The ultimate goal of **Sample Godot Rust App** is to abstract a lot of tedious tasks, save money wherever possible and focus on game development, while all the extra work is done remotely via pre-configured multi-platform continuous integration, for the following platforms :

| OS | Build | Export | Signed |
| -- | ----- | ------ | ------ |
| <p style="display: flex;"><img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="28" width="28" style="margin-top: -2px;margin-right: 8px;"/> Windows</p> | ✅ `x86_64-pc-windows-msvc`<br />✅ `x86_64-pc-windows-gnu` | ✅ | ❓💰<sup>**[1]**</sup> |
| <p style="display: flex;"><img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="35" width="36" style="margin-top: -2px;margin-right: 8px;"/> Linux</p> | ✅ `x86_64-unknown-linux-gnu` | ✅ | ❓ |
| <p style="display: flex;"><img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="28" width="28" style="margin-top: -2px;margin-right: 8px;"/>Mac OS</p> | ✅ `x86_64-apple-darwin` | ✅ | ❓💰<sup>**[2]**</sup> |
| <p style="display: flex;"><img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="32" width="32" style="margin-top: -2px;margin-right: 8px;"/>Android</p> | ✅ `aarch64-linux-android `<br />✅ `x86_64-linux-android `<br />✅ `armv7-linux-androideabi`<sup>**[3]**</sup><br />✅ `i686-linux-android `<sup>**[3]**</sup> | ✅ | ✅ |
| <p style="display: flex;"><img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="28" width="28" style="margin-top: -2px;margin-right: 8px;"/>iOS</p> | ✅ `aarch64-apple-ios`<br />✅ `x86_64-apple-ios`<br />❌ `armv7-apple-ios`<sup>**[4]**</sup><br />❌ `armv7s-apple-ios`<sup>**[4]**</sup><br />❌ `i386-apple-ios`<sup>**[4]**</sup><br /> | ✅ | ❓💰<sup>**[2]**</sup> |

✅ Supported
💰 Paid
❓ Untested
❌ Not supported

<sup>**[1]** → _Requires [Windows Authenticode code signing certificate](https://www.sslshopper.com/microsoft-authenticode-certificates.html) (annual fees)._</sup><br />
<sup>**[2]** → _Requires [Apple Developer Program subscription](https://developer.apple.com/programs/) (annual fees)._</sup><br />
<sup>**[3]** → _Google [will drop support for 32-bit programs](https://android-developers.googleblog.com/2019/01/get-your-apps-ready-for-64-bit.html) in August 2021, Rust might stop support for any related toolchain by then._</sup><br />
<sup>**[4]** → _Starting from macOS 10.15 and iOS 11, Apple [dropped support for 32-bit programs](https://blog.rust-lang.org/2020/01/03/reducing-support-for-32-bit-apple-targets.html). Any related Rust toolchain is now unsupported._</sup><br />

<br></br>

See the next chapter for the requirements to use **Sample Godot Rust App**.