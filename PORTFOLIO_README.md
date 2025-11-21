# Portfolio & Alexandria Dock - Access Guide

Ce document explique comment accéder aux pages portfolio et Alexandria Dock depuis Second-Me.

## Localisation

Les pages sont situées dans le projet Next.js :
- **Chemin principal** : `/home/ichigo/alexandria/anima-mundi/frontend/v0-integrations-page`
- **Lien symbolique** : `/home/ichigo/Second-Me/portfolio-app`

## Pages disponibles

### 1. Portfolio Personnel (xaiksan1)
- **URL** : `http://localhost:3000/portfolio`
- **Description** : Portfolio personnel avec compétences et projets
- **Technologies** : Next.js, TypeScript, Framer Motion, TailwindCSS

### 2. Alexandria Dock
- **URL** : `http://localhost:3000/alexandria-dock`
- **Description** : Page de présentation du gestionnaire Docker Home Lab
- **Technologies** : Next.js, TypeScript, TailwindCSS, Shadcn UI

### 3. Intégrations
- **URL** : `http://localhost:3000/integrations`
- **Description** : Page d'intégrations avec pagination et filtres
- **Technologies** : Next.js, TypeScript, TailwindCSS

## Lancement du serveur

```bash
# Se déplacer dans le répertoire
cd /home/ichigo/Second-Me/portfolio-app
# ou
cd /home/ichigo/alexandria/anima-mundi/frontend/v0-integrations-page

# Installer les dépendances (si nécessaire)
pnpm install

# Lancer le serveur de développement
pnpm dev

# Ouvrir dans le navigateur
# http://localhost:3000/portfolio
# http://localhost:3000/alexandria-dock
# http://localhost:3000/integrations
```

## Structure des fichiers

```
portfolio-app/
├── app/
│   ├── portfolio/
│   │   └── page.tsx          # Page portfolio personnalisée
│   ├── alexandria-dock/
│   │   └── page.tsx          # Page Alexandria Dock
│   ├── integrations/
│   │   └── page.tsx          # Page intégrations
│   └── layout.tsx
├── components/
│   └── ui/                   # Composants UI Shadcn
├── public/
│   └── images/               # Images du portfolio
└── package.json
```

## Personnalisation

Les pages ont été créées avec vos informations :
- **Nom** : xaiksan1
- **Email** : michaellefebvre416@gmail.com
- **GitHub** : https://github.com/xaiksan1
- **Projets** : Anima Mundi, Alexandria Dock, Second-Me

Pour modifier ces informations, éditez les fichiers :
- `/app/portfolio/page.tsx`
- `/app/alexandria-dock/page.tsx`

## Notes

- Le projet utilise **pnpm** comme gestionnaire de packages
- **Framer Motion** a été installé pour les animations
- Les pages sont entièrement responsive
- Les composants UI utilisent **Shadcn UI** et **TailwindCSS**

---

Développé pour **Second-Me** par xaiksan1
