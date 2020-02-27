# ドライブごとにしきい値を設定
$min_freespace = @{
    "C" = 30GB;
    "D" = 10GB;
    "E" = 50GB;
}

function ShowBalloonTip(
    [string] $tilte = "件名", 
    [string] $body = "本文"
) {
    #[Reference]
    # PowerShell can I use balloons, toasts and notifications?
    #   https://deploywindows.info/2015/12/01/powershell-can-i-use-balloons-toasts-and-notifications/
    # Toasts templates
    #   https://msdn.microsoft.com/en-us/library/windows/apps/hh761494.aspx

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    echo 'v$template'
    $template.GetType().FullName
    # Convert to .NET type for XML manipuration
    $toastXml = [xml] $template.GetXml()

    echo 'v$toastXml'
    $toastXml.GetType().FullName
    echo 'v$toastXml Nakami'
    echo $toastXml
    # Customize the toast message
    $text = $toastXml.GetElementsByTagName("text")
    $text[0].AppendChild($toastXml.CreateTextNode($tilte)) > $null
    $text[1].AppendChild($toastXml.CreateTextNode($body)) > $null

    # Convert back to WinRT type
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($toastXml.OuterXml)
    $Toast = [Windows.UI.Notifications.ToastNotification]::new($xml)

    $AppID = 'Microsoft.Explorer.Notification.{3e1c1f24-a023-49cf-98ff-90cdabb9930b}'

    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($Toast)
}

$msg = ""
foreach ($drive_letter in $min_freespace.Keys) {
    $drive = Get-PSDrive $drive_letter
    if ( $drive.Free -lt $min_freespace[$drive_letter] ) {
        $msg += "{0}ドライブ空き容量:{1,0:0.00}GB`n" -f $drive_letter, ($drive.Free/1GB);
    }
}

if ( $msg ) { 
    ShowBalloonTip "空き容量警告" $msg
}