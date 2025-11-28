function Convert-DocxToText {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DocxFilePath,

        [Parameter(Mandatory=$true)]
        [string]$TextFilePath
    )

    # Ensure the input file exists
    if (-not (Test-Path $DocxFilePath)) {
        Write-Error "DOCX file not found: $DocxFilePath"
        return
    }

    # Create a Word Application object
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false

    try {
        # Open the DOCX document
        $doc = $word.Documents.Open($DocxFilePath)

        # Define the save format for plain text (wdFormatText)
        $saveFormat = [Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatText

        # Save the document as plain text
        $doc.SaveAs([ref]$TextFilePath, [ref]$saveFormat)

        Write-Host "Successfully converted '$DocxFilePath' to '$TextFilePath'."
    }
    catch {
        Write-Error "An error occurred during conversion: $($_.Exception.Message)"
    }
    finally {
        # Close the document and quit the Word application
        if ($doc -ne $null) {
            $doc.Close()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($doc) | Out-Null
        }
        if ($word -ne $null) {
            $word.Quit()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
        }
        Remove-Variable -Name word, doc -ErrorAction SilentlyContinue
    }
}

$inputDocx = "D:\attendance\attendance\system req (1).docx"
$outputTxt = "D:\attendance\attendance\system_req.txt"

Convert-DocxToText -DocxFilePath $inputDocx -TextFilePath $outputTxt
