#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h:h}"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Packaging/Info.plist")
PACKAGE="${1:-$ROOT/dist/vRemoter-$VERSION-AppleSilicon.pkg}"
python3 - "$ROOT" "$PACKAGE" "$VERSION" <<'PY'
import pathlib, plistlib, subprocess, sys, tempfile, xml.etree.ElementTree as ET
root, package, version = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
with tempfile.TemporaryDirectory(prefix='vremoter-package-test-') as temp:
    expanded = pathlib.Path(temp)/'expanded'
    subprocess.run(['pkgutil','--expand-full',str(package),str(expanded)],check=True)
    distribution = ET.parse(expanded/'Distribution').getroot()
    assert distribution.find('options').get('hostArchitectures') == 'arm64'
    assert distribution.find('volume-check/allowed-os-versions/os-version').get('min') == '12.0'
    component = expanded/'vRemoter-component.pkg'
    info = ET.parse(component/'PackageInfo').getroot()
    assert info.get('relocatable') == 'false'
    assert info.get('auth') == 'root'
    assert info.get('identifier') == 'local.simaqingfeng.vRemoter.pkg'
    assert len(info.findall('relocate/bundle')) == 0
    app = component/'Payload/Applications/vRemote.app'
    driver = component/'Payload/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver'
    for bundle, identifier in [(app,'local.simaqingfeng.vRemote'),(driver,'audio.local.vRemoteDriver2chXX')]:
        bundle_info = plistlib.loads((bundle/'Contents/Info.plist').read_bytes())
        assert bundle_info['CFBundleIdentifier'] == identifier
        subprocess.run(['codesign','--verify','--deep','--strict',str(bundle)],check=True)
    assert plistlib.loads((app/'Contents/Info.plist').read_bytes())['CFBundleShortVersionString'] == version
    subprocess.run(['lipo',str(app/'Contents/MacOS/vRemote'),'-verify_arch','arm64'],check=True)
    assert (driver/'Contents/Resources/LICENSE.txt').read_bytes() == (root/'Driver/BlackHole/LICENSE').read_bytes()
    assert not (app/'Contents/Resources/BuyMeACoffee').exists()
    for script in ('preinstall','postinstall'):
        packaged = component/'Scripts'/script
        assert packaged.read_bytes() == (root/'Packaging/pkg-scripts'/script).read_bytes()
        subprocess.run(['sh','-n',str(packaged)],check=True)
    # This loads the driver's executable from a fresh extraction of the delivered PKG.
    subprocess.run(['zsh',str(root/'Scripts/test-driver.sh'),str(driver)],check=True)
    print('PASS: standalone PKG includes signed App + working source-built driver, license, fixed locations and install scripts')
PY
