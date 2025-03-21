#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=code_barres_porte_cle.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
	;---------------------------------------------------------------------------------------------------------
	;                         Application MOK_BAR
	;---------------------------------------------------------------------------------------------------------
	; application qui permet l'impression de badges pour se connecter sur Manhattan
	;
	;
	;
	;
	;---------------------------------------------------------------------------------------------------------
	; Auteur : Mokhtar.Benyahia (octobre 2023)
	;---------------------------------------------------------------------------------------------------------
	; Version : V0.0 le 20 octobre 2023
    ; Version : V0.1 le 16 novembre 2023
    ; Version : V0.2 le 24 janvier  2024
	;---------------------------------------------------------------------------------------------------------
	; Lancement V0.0			:Mise en production de l'appication V0 (testé le 20 octobre 2023)
	; Modificaton V0.1	     	:Ajout de la fonction _URLEncode pour l'ajout des caractères spéciaux dans le QR-code
    ; Modificaton V0.2	     	:Ajout de GDIPlus pour créer une image permettant d'imprimer le qr code id et l'email en texte sur la meme impression
	;
	;---------------------------------------------------------------------------------------------------------




#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <TabConstants.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <ColorConstants.au3>
#include <Timers.au3>
#include <GuiTab.au3>
#include <GuiComboBox.au3>
#include <date.au3>
#include <GuiListBox.au3>
#include <GuiListView.au3>
#include <file.au3>
#include <_SQL.au3>
#include <Array.au3>
#include <String.au3>
#include <GuiButton.au3>
#include <GuiToolbar.au3>
#include <ComboConstants.au3>
#include <Crypt.au3>
#include <Excel.au3>


Global $Z_Ident, $H_Ident, $W_Zone, $MotDePasse, $Identifiant, $Lib_Nom

Global $INSTANCE_SQL 	= 'FRROYESQL01P'
Global $NOM_BDD 		= 'APPLI_CHARIOT'


$Version_prog = "V0.02"

	;---------------------------------------------------------------------------------------------------------
	;                          Déclaration des valeurs par défaut
	;---------------------------------------------------------------------------------------------------------
; si un paramètre est passé au prog c'est qu'on est en test

if Prog_primaire () = 0 Then
    ;GUIDelete()
	;Prog_Principal()
EndIf

    ; ---------------------------------------------------------------------------------------------
func Prog_primaire ()



;Création de la première page
	$Ecran_Accueil =  GUICreate("MOK_BAR "& $Version_prog & " (" & $Lib_Nom & " )",600,400) ; Permet de créer une boîte de dialogue qui s'affichera au centre


   ;---------------------------------------------------------------------------------------------------------------------
   ; Créer la page d'accueil
   ;---------------------------------------------------------------------------------------------------------------------

		 global $AfficherCompte = GUICtrlCreateLabel("", 230, 20, 300,40)

		 global $AfficherMajMdp =GUICtrlCreateLabel("", 410, 260, 200,40)

		 $picturemanhattan = GUICtrlCreatePic("manhattan.jpg", 0, 0, 220, 40)

		 $titleApp1 = GUICtrlCreateLabel (" MOKBAR", 20, 30, 120, 120)
		 GUICtrlSetFont($titleApp1, 12, 800) ; 800 pour gras, 400 pour normal
		 GUICtrlSetColor($titleApp1, 0xFF0000) ; 0xFF0000 est la couleur rouge en notation hexadécimale RGB

		 $titleApp2 = GUICtrlCreateLabel ("Application d'impression QR-code pour Manhattan", 160, 30, 550, 20)
		 GUICtrlSetFont($titleApp2, 12, 800) ; 800 pour gras, 400 pour normal

		 GUICtrlCreateLabel(" Scannez votre identifiant : ", 200,110,200,20)
		 $Identifiant = GUICtrlCreateinput  ("@loreal.com" ,   100, 130, 300, 20,$ES_UPPERCASE, $BS_GROUPBOX)
		 GUICtrlSetOnEvent($Identifiant, "HandleIdInputChange") ; Associe l'événement à la modification de la valeur de l'identifiant
		 ;GUICtrlSetState($H_Ident,$GUI_DISABLE )

		 ; bouton d'impression du code barre Identifiant qui s'affiche quand l'utilisateur se connecte
		 $Button_Print_Id = GUICtrlCreateButton("Imprimer QR-code Identifiant", 420, 110, 160, 50, $BS_ICON) ; Créer un bouton pour imprimer le QR code ID

		 GUICtrlCreateLabel(" Scannez votre mot de passe : ", 201,200,201,21)
		 $MotDePasse = GUICtrlCreateinput  ("" ,   100, 220, 300, 20, $ES_PASSWORD)
		 ; GUICtrlSetState($MotDePasse, $GUI_DISABLE)

		 ;bouton d'impression du QR-code mot de passe qui s'affiche quand l'utilisateur se connecte
		 $Button_Print_mdp = GUICtrlCreateButton("Imprimer QR-code mot-de-passe", 420, 200, 160, 50, $BS_ICON)

		 $supprimer = GUICtrlCreateButton("Effacer", 260, 260, 80,40)

		 ; Ajout des champs pour le nombre d'impressions
		 GUICtrlCreateLabel("Nombre d'impressions pour l'identifiant :", 10, 330, 250, 20)
		 $Nombre_Impressions_Id = GUICtrlCreateInput("1", 260, 330, 50, 20)

		 GUICtrlCreateLabel("Nombre d'impressions pour le mot de passe :", 10, 360, 250, 20)
		 $Nombre_Impressions_Mdp = GUICtrlCreateInput("1", 260, 360, 50, 20)


   ;---------------------------------------------------------------------------------------------------------------------
	  ;Affichage de la page et lancement de la bouche et les différents cas
   ;---------------------------------------------------------------------------------------------------------------------


	GUISetState(@SW_SHOW)

		 While 1
			 Switch GUIGetMsg()
				 Case $GUI_EVENT_CLOSE
					 Exit

				 Case $Button_Print_Id  ;boutton impression qr code de l'identifiant

					 Local $sId = GUICtrlRead($Identifiant)
					 Local $nImpressionsId = GUICtrlRead($Nombre_Impressions_Id)

					 if IsValidIdentifier($sId) Then
						For $i = 1 To $nImpressionsId
						 DownloadQRCode($sId, @TempDir & "\id.png")
						 Sleep(200)
						 Local $sImageIdFilePath = @TempDir & "\id.png"
						 While Not FileExists($sImageIdFilePath)
							 Sleep(1000)
						 WEnd

						  sleep(200)
						  ; Création du fichier de commandes pour l'imprimante Zebra
						  Local $hFile = FileOpen(@TempDir & "\Fic_Impr_Zebra.txt", $FO_OVERWRITE)

						  ; Écrire les commandes ZPL dans le fichier
						  FileWrite($hFile, "^XA" & @CRLF) ; Début du script ZPL
						  FileWrite($hFile, "^LH0,0" & @CRLF) ; Position de départ
						  FileWrite($hFile, "^CFA,30" & @CRLF) ; Font size pour le texte
						  FileWrite($hFile, "^FO50,50^FD" & $sId & "^FS" & @CRLF) ; Texte en gras (ID)
						  FileWrite($hFile, "^FO50,100^BQN,2,7" & @CRLF) ; QR code
						  FileWrite($hFile, "^FDMA," & $sId & "^FS" & @CRLF) ; Données du QR code
						  FileWrite($hFile, "^XZ" & @CRLF) ; Fin du script ZPL

						  FileClose($hFile)
						  sleep(200)
						  ; Ouvrir le fichier pour un aperçu
						  ;ShellExecute(@TempDir & "\Fic_Impr_Zebra.txt")

						  ; Imprimer le fichier de commandes
						  ;Local $Printer = "Nom_Imprimante_Zebra"

						  ;Run(@ComSpec & " /c type " & @TempDir & "\Fic_Impr_Zebra.txt > " & $Printer, "", @SW_HIDE)

						   ;2 Méthode d'impression via notepad, comme celui utilisé par cb-caisse
						  ;Run(@SystemDir & '\notepad.exe /p "' & @TempDir & "\Fic_Impr_Zebra.txt" , '' ,@SW_HIDE)

						  ;3eme méthode d'impression via copy
						  Local $Printer = "ZEBRA_LOCALE"
						  RunWait(@ComSpec & " /c copy /b " & $hFile & " " & $Printer, "", @SW_HIDE)

						 Sleep(300)
						 FileDelete($hFile)

						Next
					 Else
						 MsgBox(0, "Identifiant incorrect", "L'adresse saisie ne correspond pas au format @loreal.com")
					 EndIf

				 case $Button_Print_mdp ; boutton impression qr code du mot-de-passe

					Local $sPassword = GUICtrlRead($MotDePasse)
					Local $nImpressionsMdp = GUICtrlRead($Nombre_Impressions_Mdp)

					if StringLen($sPassword) >= 8 Then

					   For $i = 1 To $nImpressionsId

					   ;function DownloadQRCode appelle l'API google chart pour transformer le texte en QRcode
					   DownloadQRCode($sPassword, @TempDir&"\mdp.png")
					   sleep(200)

					   Local $sImageMdpFilePath = @TempDir&"\mdp.png"

					   while not FileExists($sImageMdpFilePath)

						sleep(500)

					   WEnd

						sleep(300)

					   ; lance l'impression via mspaint sans fenêtre intèrmédiaire a l'aide de l'outil Paint
					   RunWait(@ComSpec & " /c mspaint /pt " & $sImageMdpFilePath, "", @SW_HIDE)

					   sleep(300)

					   FileDelete($sImageMdpFilePath)


					   ConsoleWrite($sPassword&" "&" a bien été imprimer")
					 Next

					   else

					   MsgBox(0,"Impression mot-de-passe", "Votre mot de passe doit contenir au moins 8 caracteres")

					EndIf


			  case $supprimer  ; nous supprimons les champs identifiants et mot de passe après avoir cliquer sur le boutton effacer

				 GUICtrlSetData($Identifiant, "")
			     GUICtrlSetData($MotDePasse, "")
				 GUICtrlSetData($Nombre_Impressions_Id, "1")
                 GUICtrlSetData($Nombre_Impressions_Mdp, "1")

			 EndSwitch
		 WEnd


EndFunc

; fin fonction primaire  -----------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------------------------
;Vérifier l'utilisateur
;---------------------------------------------------------------------------------------------------------

Func UtilisateurExist($Id, $Password)

	 local $aResult,$iRows, $iColumns

	 _SQL_Startup()

	 ConsoleWrite("entrerFonction")

	   ; Ouvrir la connexion à la base de données
	   _SQL_Connect(-1, $INSTANCE_SQL, $NOM_BDD, "", "")

	   If @error Then

		 Return SetError(@error, @extended, False)
	   EndIf
	   ; Exécuter la requête SQL

	   local $sQuery = "SELECT * FROM Mokbar WHERE Identifiant='" & $Id & "' AND Mot_de_passe ='" & $Password & "' "

	   ConsoleWrite($sQuery&@CRLF)

	   local $SQL_err = _SQL_GetTable(-1, $sQuery,  $aResult,  $iRows,  $iColumns)


	   ; Vérifier si un enregistrement a été trouvé
	   if  $iRows > 0 then

		 _ArrayDisplay($aResult)

		  $TypeCompte = $aResult[12]

		  $MajMdp = $aResult[14]

    	   ; Convertir la date au format jour/mois/année
		   $FormattedDate = FormatDate($MajMdp)

		  GUICtrlSetData($AfficherCompte, "Type de compte : " & $aResult[12])
		  GUICtrlSetFont($AfficherCompte, 12, 800) ; 800 pour gras, 400 pour normal
		  GUICtrlSetColor($AfficherCompte, 0xFF0000) ; 0xFF0000 est la couleur rouge en notation hexadécimale RGB

		  GUICtrlSetData($AfficherMajMdp,"Votre mot de passe a été mis à jour le "&$FormattedDate)

		  _SQL_Close()

		  Return True
		  Else
		   GUICtrlSetData($AfficherCompte, "")

		   GUICtrlSetData($AfficherMajMdp, "")

		   _SQL_Close()

			Return False
	   EndIf

EndFunc

;---------------------------------------------------------------------------------------------------------
;Formtater la date au format JJ/MM/AAAA
;---------------------------------------------------------------------------------------------------------

Func FormatDate($date)
    ; Convertir la date au format JJ/MM/AAAA
    Local $aDate = StringSplit($date, "-")
    If UBound($aDate) > 3 Then
        Return $aDate[3] & "-" & $aDate[2] & "-" & $aDate[1]
    EndIf
    Return $date
 EndFunc

 ;---------------------------------------------------------------------------------------------------------
;Fonction encryptage qui utilise l'algorithme AES 256
;~ ;-------------------------------------------------------------------------------------------------------

Func _Encrypt($sKey, $sData)
  Local $hKey = _Crypt_DeriveKey($sKey, $CALG_AES_256)
  Local $sEncrypted = _Crypt_EncryptData($sData, $hKey, $CALG_USERKEY)
  _Crypt_DestroyKey($hKey)
  ClipPut($sEncrypted)
  Return $sEncrypted
EndFunc

 ;---------------------------------------------------------------------------------------------------------
;Fonction de decryptage qui utilise l'algorithme AES 256
;~ ;-------------------------------------------------------------------------------------------------------

Func _Decrypt($sKey, $sData)
  Local $hKey = _Crypt_DeriveKey($sKey, $CALG_AES_256)
  Local $sDecrypted = BinaryToString(_Crypt_DecryptData(Binary($sData), $hKey, $CALG_USERKEY))
  _Crypt_DestroyKey($hKey)
  Return $sDecrypted
EndFunc

;---------------------------------------------------------------------------------------------------------
;Enlever les accents
;---------------------------------------------------------------------------------------------------------


Func _ChaineSansAccents($sString)
    Dim $Var1[28] = ["à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ò", "ó", "ô", "ö", "ù", "ú", "û", "ü", "ý","œ","É","’"]
    Dim $Var2[28] = ["a", "a", "a", "a", "a", "a", "ae", "c", "e", "e", "e", "e", "i", "i", "i", "i", "o", "o", "o", "o", "u", "u", "u", "u", "y","oe","E"," "]

    For $i = 0 To UBound($Var1) - 1
        $sString = StringRegExpReplace($sString, $Var1[$i], $Var2[$i])
    Next
    Return $sString
 EndFunc


 ;---------------------------------------------------------------------------------------------------------
;Fonction API QR CODE
;---------------------------------------------------------------------------------------------------------

Func DownloadQRCode($data, $savePath)
    Local $encodedData = _URLEncode($data)
    Local $sURL = "https://chart.googleapis.com/chart?chs=50x50&cht=qr&chl=" & $encodedData
	sleep(200)
    InetGet($sURL, $savePath, 1, 1)
 EndFunc

;---------------------------------------------------------------------------------------------------------
;Fonction pour encoder une chaîne pour une utilisation dans une URL
;---------------------------------------------------------------------------------------------------------

; Fonction pour encoder une chaîne pour une utilisation dans une URL
Func _URLEncode($sString)
    Local $sResult = ""
    For $i = 1 To StringLen($sString)
        Local $sChar = StringMid($sString, $i, 1)
        Local $iAsc = Asc($sChar)
        If ($iAsc > 47 And $iAsc < 58) Or ($iAsc > 64 And $iAsc < 91) Or ($iAsc > 96 And $iAsc < 123) Or $iAsc = 45 Or $iAsc = 46 Or $iAsc = 95 Or $iAsc = 126 Then
            $sResult &= $sChar
        Else
            $sResult &= "%" & Hex($iAsc, 2)
        EndIf
    Next
    Return $sResult
EndFunc


 ;---------------------------------------------------------------------------------------------------------
;Fonction qui détecte les changements dans l'input ID
;---------------------------------------------------------------------------------------------------------

Func HandleIdInputChange()
    Local $sIdValue = GUICtrlRead($Identifiant) ; Lire la valeur du champ identifiant
    If $sIdValue <> "" Then ; Si le champ identifiant contient au moins un caractère
        GUICtrlSetState($MotDePasse, $GUI_ENABLE) ; Activer le champ mot de passe
    Else
        GUICtrlSetState($MotDePasse, $GUI_DISABLE) ; Sinon, désactiver le champ mot de passe
    EndIf
 EndFunc

 ;---------------------------------------------------------------------------------------------------------
;Fonction qui vérifie le format de l'id au format *************@loreal.com
;---------------------------------------------------------------------------------------------------------

 Func IsValidIdentifier($id)

    ; Ici, on vérifie qu'il y ait n'importe quel caractère suivi de '@loreal.com'
    Local $regex = "^.+@LOREAL\.COM$"

    If StringRegExp($id, $regex) Then
        Return True
    Else
        Return False
    EndIf
EndFunc
