# 🏢  Application Mokbar- Générateur de QR Code pour Identifiants

![Logo de l'entreprise](https://www.ericmilliard.com/wp-content/uploads/2017/02/l-oreal-luxe.jpg)

## 🎯 Objectif

Ce projet a pour but de fournir une **interface simple** permettant de saisir un identifiant et un mot de passe, puis de **générer un QR Code** encodant ces informations. Ce QR Code peut ensuite être scanné pour un accès rapide et sécurisé.

---

## 📸 Interface Utilisateur

![Capture d'écran de l'interface](./Interface_Mokbar.png)

L'interface graphique comprend :

- Un champ pour saisir l'**Identifiant**
avec une regex forcant les majuscules et l'id = LOREAL.COM
- Un champ pour saisir le **Mot de passe**
- Un bouton **"Générer QR Code"**
- Une zone d'affichage du **QR Code généré**
- Un bouton de réinitialisation qui efface tout

---

## ⚙️ Fonctionnement technique

Ce projet est construit en **Python** avec **Tkinter** pour l'interface graphique et **qrcode** pour générer le QR Code.

Vous pouvez trouver une version en Auto IT qui utilise l'API https://chart.googleapis.com/chart?chs=50x50&cht=qr&chl= 

### 🔧 Installation des dépendances

Assure-toi d'avoir Python installé, puis installe les dépendances :

```bash
pip install qrcode[pil] pillow
