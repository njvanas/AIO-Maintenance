@echo off
:: Google Chrome
if exist "%LocalAppData%\Google\Chrome\User Data\Default\Cookies" (
    del /q /s "%LocalAppData%\Google\Chrome\User Data\Default\Cookies"
    del /q /s "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*"
)
:: Microsoft Edge
if exist "%LocalAppData%\Microsoft\Edge\User Data\Default\Cookies" (
    del /q /s "%LocalAppData%\Microsoft\Edge\User Data\Default\Cookies"
    del /q /s "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*"
)
:: Mozilla Firefox
if exist "%AppData%\Mozilla\Firefox\Profiles" (
    for /d %%D in ("%AppData%\Mozilla\Firefox\Profiles\*") do (
        del /q /s "%%D\cookies.sqlite"
        del /q /s "%%D\cache2\entries\*"
    )
)
:: Opera
if exist "%AppData%\Opera Software\Opera Stable\Cookies" (
    del /q /s "%AppData%\Opera Software\Opera Stable\Cookies"
    del /q /s "%AppData%\Opera Software\Opera Stable\Cache\*"
)
:: Brave
if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cookies" (
    del /q /s "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cookies"
    del /q /s "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache\*"
)
:: Vivaldi
if exist "%LocalAppData%\Vivaldi\User Data\Default\Cookies" (
    del /q /s "%LocalAppData%\Vivaldi\User Data\Default\Cookies"
    del /q /s "%LocalAppData%\Vivaldi\User Data\Default\Cache\*"
)
:: Tor Browser
if exist "%AppData%\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\cookies.sqlite" (
    del /q /s "%AppData%\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\cookies.sqlite"
    del /q /s "%AppData%\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\Cache\*"
)
:: Epic Privacy Browser
if exist "%LocalAppData%\Epic Privacy Browser\User Data\Default\Cookies" (
    del /q /s "%LocalAppData%\Epic Privacy Browser\User Data\Default\Cookies"
    del /q /s "%LocalAppData%\Epic Privacy Browser\User Data\Default\Cache\*"
)
