# 使用するクラス宣言
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

# 引数のファイルをXMLとして読む
$template = [xml](Get-Content $Args[0])

# テンプレートXMLのtypeがmessageの要素のテキストを現在のIPアドレスに書き換える
foreach($text in $template.toast.visual.binding.text)
{
    if($text.type -eq 'message')
    {
        $text.InnerText = [String]([system.net.dns]::GetHostAddresses((hostname)) | where {$_.AddressFamily -eq "InterNetwork"} | select -ExpandProperty IPAddressToString)
    }
}

# 上で加工したXMLをtoastで使える形式に変換する
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template.OuterXml)

# Toast 通知表示
$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]:: CreateToastNotifier($app).Show($toast)
