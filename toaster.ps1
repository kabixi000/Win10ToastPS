# �g�p����N���X�錾
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

# �����̃t�@�C����XML�Ƃ��ēǂ�
$template = [xml](Get-Content $Args[0])

# �e���v���[�gXML��type��message�̗v�f�̃e�L�X�g�����݂�IP�A�h���X�ɏ���������
foreach($text in $template.toast.visual.binding.text)
{
    if($text.type -eq 'message')
    {
        $text.InnerText = [String]([system.net.dns]::GetHostAddresses((hostname)) | where {$_.AddressFamily -eq "InterNetwork"} | select -ExpandProperty IPAddressToString)
    }
}

# ��ŉ��H����XML��toast�Ŏg����`���ɕϊ�����
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template.OuterXml)

# Toast �ʒm�\��
$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
[Windows.UI.Notifications.ToastNotificationManager]:: CreateToastNotifier($app).Show($toast)
