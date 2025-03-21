import tkinter as tk
from tkinter import messagebox
import qrcode
from PIL import Image, ImageTk
import os
import re

# Regex pour valider un identifiant email se terminant par @LOREAL.COM
REGEX_ID = r"^[A-Z0-9._%+-]+@LOREAL\.COM$"

def generer_qr_texte(texte, nom_fichier):
    if not texte:
        messagebox.showerror("Erreur", "Le champ est vide.")
        return

    qr = qrcode.make(texte)
    qr.save(nom_fichier)

    image = Image.open(nom_fichier)
    image = image.resize((200, 200))
    photo = ImageTk.PhotoImage(image)

    label_qr.configure(image=photo)
    label_qr.image = photo

def generer_qr_id():
    identifiant = entry_id.get().strip().upper()
    entry_id.delete(0, tk.END)
    entry_id.insert(0, identifiant)

    if not re.match(REGEX_ID, identifiant):
        messagebox.showerror("Format invalide", "L'identifiant doit se terminer par @LOREAL.COM et être en majuscules.")
        return

    generer_qr_texte(f"Identifiant: {identifiant}", "qr_id.png")

def generer_qr_mdp():
    mot_de_passe = entry_mdp.get()
    if not mot_de_passe:
        messagebox.showerror("Erreur", "Le mot de passe ne peut pas être vide.")
        return
    generer_qr_texte(f"Mot de passe: {mot_de_passe}", "qr_mdp.png")

def effacer():
    entry_id.delete(0, tk.END)
    entry_mdp.delete(0, tk.END)
    label_qr.configure(image='')
    label_qr.image = None
    for fichier in ["qr_id.png", "qr_mdp.png"]:
        if os.path.exists(fichier):
            os.remove(fichier)

# Interface graphique
fenetre = tk.Tk()
fenetre.title("MokBar - Générateur de QR Code")

tk.Label(fenetre, text="Identifiant (ex : USER@LOREAL.COM):").pack()
entry_id = tk.Entry(fenetre)
entry_id.pack()

tk.Label(fenetre, text="Mot de passe:").pack()
entry_mdp = tk.Entry(fenetre, show="*")
entry_mdp.pack()

tk.Button(fenetre, text="QR Code Identifiant", command=generer_qr_id).pack(pady=5)
tk.Button(fenetre, text="QR Code Mot de Passe", command=generer_qr_mdp).pack(pady=5)
tk.Button(fenetre, text="Effacer", command=effacer).pack(pady=5)

label_qr = tk.Label(fenetre)
label_qr.pack(pady=10)

fenetre.mainloop()
