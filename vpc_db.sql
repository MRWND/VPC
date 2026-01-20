-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 15 jan. 2026 à 14:23
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `vpc_db`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ajouter_stock` (IN `p_id_article` INT, IN `p_quantite` INT, IN `p_id_user` INT)   BEGIN
    UPDATE stock 
    SET quantite_disponible = quantite_disponible + p_quantite
    WHERE id_article = p_id_article;
    
    INSERT INTO historique_stock (id_article, type_mouvement, quantite, motif, id_user)
    VALUES (p_id_article, 'entree', p_quantite, 'Réception fournisseur', p_id_user);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `preparer_commande` (IN `p_id_commande` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_article INT;
    DECLARE v_quantite INT;
    DECLARE cur CURSOR FOR 
        SELECT id_article, quantite 
        FROM lignes_commande 
        WHERE id_commande = p_id_commande;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_id_article, v_quantite;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Décrémenter le stock
        UPDATE stock 
        SET quantite_disponible = quantite_disponible - v_quantite
        WHERE id_article = v_id_article;
        
        -- Historique
        INSERT INTO historique_stock (id_article, type_mouvement, quantite, motif)
        VALUES (v_id_article, 'sortie', v_quantite, CONCAT('Commande #', p_id_commande));
    END LOOP;
    
    CLOSE cur;
    
    -- Mettre à jour le statut de la commande
    UPDATE commandes 
    SET statut = 'preparee', date_preparation = NOW()
    WHERE id_commande = p_id_commande;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `valider_commande` (IN `p_id_commande` INT)   BEGIN
    UPDATE commandes 
    SET statut = 'validee', date_validation = NOW()
    WHERE id_commande = p_id_commande;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `articles`
--

CREATE TABLE `articles` (
  `id_article` int(11) NOT NULL,
  `reference` varchar(50) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `prix` decimal(10,2) NOT NULL,
  `id_categorie` int(11) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `actif` tinyint(1) DEFAULT 1,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `articles`
--

INSERT INTO `articles` (`id_article`, `reference`, `nom`, `description`, `prix`, `id_categorie`, `photo`, `actif`, `date_ajout`) VALUES
(1, 'PC-DELL-001', 'Dell XPS 15', 'PC portable 15 pouces, Intel i7, 16Go RAM, 512Go SSD', 1299.99, 1, 'dell_xps15.jpg', 1, '2026-01-15 11:26:40'),
(2, 'PC-HP-002', 'HP Pavilion Gaming', 'PC portable gamer, RTX 3060, 16Go RAM, 1To SSD', 999.99, 1, 'hp_pavilion.jpg', 1, '2026-01-15 11:26:40'),
(3, 'PC-ASUS-003', 'ASUS ROG Strix', 'PC portable gamer haut de gamme, RTX 4070, 32Go RAM', 1899.99, 1, 'asus_rog.jpg', 1, '2026-01-15 11:26:40'),
(4, 'TEL-SAM-001', 'Samsung Galaxy S24', 'Smartphone 5G, 256Go, écran AMOLED', 899.99, 2, 'galaxy_s24.jpg', 1, '2026-01-15 11:26:40'),
(5, 'TEL-APP-002', 'iPhone 15 Pro', 'iPhone dernière génération, 256Go', 1199.99, 2, 'iphone15.jpg', 1, '2026-01-15 11:26:40'),
(6, 'TEL-XIA-003', 'Xiaomi 13T Pro', 'Smartphone 5G, 512Go, charge rapide 120W', 649.99, 2, 'xiaomi_13t.jpg', 1, '2026-01-15 11:26:40'),
(7, 'PER-LOG-001', 'Logitech MX Master 3', 'Souris ergonomique sans fil', 99.99, 3, 'mx_master3.jpg', 1, '2026-01-15 11:26:40'),
(8, 'PER-RAZ-002', 'Razer BlackWidow V3', 'Clavier mécanique RGB gaming', 139.99, 3, 'blackwidow.jpg', 1, '2026-01-15 11:26:40'),
(9, 'PER-DEL-003', 'Dell UltraSharp U2723DE', 'Écran 27 pouces QHD, USB-C', 549.99, 3, 'dell_screen.jpg', 1, '2026-01-15 11:26:40'),
(10, 'AUD-SON-001', 'Sony WH-1000XM5', 'Casque bluetooth réduction de bruit', 349.99, 4, 'sony_xm5.jpg', 1, '2026-01-15 11:26:40'),
(11, 'AUD-APP-002', 'AirPods Pro 2', 'Écouteurs sans fil Apple', 279.99, 4, 'airpods_pro.jpg', 1, '2026-01-15 11:26:40'),
(12, 'AUD-JBL-003', 'JBL Charge 5', 'Enceinte portable bluetooth', 149.99, 4, 'jbl_charge5.jpg', 1, '2026-01-15 11:26:40'),
(13, 'CMP-NVI-001', 'NVIDIA RTX 4070', 'Carte graphique 12Go GDDR6X', 649.99, 5, 'rtx4070.jpg', 1, '2026-01-15 11:26:40'),
(14, 'CMP-COR-002', 'Corsair Vengeance 32Go', 'Barrette RAM DDR5 32Go', 149.99, 5, 'corsair_ram.jpg', 1, '2026-01-15 11:26:40'),
(15, 'CMP-SAM-003', 'Samsung 980 Pro 1To', 'SSD NVMe M.2 1To', 129.99, 5, 'samsung_ssd.jpg', 1, '2026-01-15 11:26:40');

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

CREATE TABLE `categories` (
  `id_categorie` int(11) NOT NULL,
  `nom_categorie` varchar(50) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `categories`
--

INSERT INTO `categories` (`id_categorie`, `nom_categorie`, `description`) VALUES
(1, 'Ordinateurs', 'PC portables et de bureau'),
(2, 'Smartphones', 'Téléphones et accessoires'),
(3, 'Périphériques', 'Claviers, souris, écrans'),
(4, 'Audio', 'Casques, enceintes, écouteurs'),
(5, 'Composants', 'Cartes graphiques, RAM, SSD');

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `id_client` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `adresse` varchar(200) NOT NULL,
  `code_postal` varchar(10) NOT NULL,
  `ville` varchar(50) NOT NULL,
  `date_inscription` timestamp NOT NULL DEFAULT current_timestamp(),
  `actif` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `clients`
--

INSERT INTO `clients` (`id_client`, `nom`, `prenom`, `email`, `password`, `telephone`, `adresse`, `code_postal`, `ville`, `date_inscription`, `actif`) VALUES
(1, 'Durand', 'Pierre', 'pierre.durand@email.com', '$2y$10$8K1p/a0dL3Zhxkr9/OjGeOJVrL4hjDvqRlFpYHpGbpqEV5v5yqKY6', '0612345678', '12 Rue de la République', '83510', 'Lorgues', '2026-01-15 11:26:40', 1),
(2, 'Lefebvre', 'Marie', 'marie.lefebvre@email.com', '$2y$10$8K1p/a0dL3Zhxkr9/OjGeOJVrL4hjDvqRlFpYHpGbpqEV5v5yqKY6', '0623456789', '45 Avenue du Général de Gaulle', '06000', 'Nice', '2026-01-15 11:26:40', 1),
(3, 'Michel', 'Jean', 'jean.michel@email.com', '$2y$10$8K1p/a0dL3Zhxkr9/OjGeOJVrL4hjDvqRlFpYHpGbpqEV5v5yqKY6', '0634567890', '78 Boulevard Victor Hugo', '13001', 'Marseille', '2026-01-15 11:26:40', 1),
(4, 'Petit', 'Claire', 'claire.petit@email.com', '$2y$10$8K1p/a0dL3Zhxkr9/OjGeOJVrL4hjDvqRlFpYHpGbpqEV5v5yqKY6', '0645678901', '23 Rue des Lilas', '83000', 'Toulon', '2026-01-15 11:26:40', 1);

-- --------------------------------------------------------

--
-- Structure de la table `commandes`
--

CREATE TABLE `commandes` (
  `id_commande` int(11) NOT NULL,
  `id_client` int(11) NOT NULL,
  `date_commande` timestamp NOT NULL DEFAULT current_timestamp(),
  `statut` enum('en_attente','validee','en_preparation','preparee','expediee','livree','annulee') DEFAULT 'en_attente',
  `montant_total` decimal(10,2) NOT NULL,
  `frais_port` decimal(10,2) DEFAULT 0.00,
  `poids_colis` decimal(10,2) DEFAULT 0.00,
  `adresse_livraison` varchar(200) NOT NULL,
  `date_validation` timestamp NULL DEFAULT NULL,
  `date_preparation` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commandes`
--

INSERT INTO `commandes` (`id_commande`, `id_client`, `date_commande`, `statut`, `montant_total`, `frais_port`, `poids_colis`, `adresse_livraison`, `date_validation`, `date_preparation`) VALUES
(1, 1, '2026-01-15 11:26:40', 'validee', 1549.97, 8.50, 0.00, '12 Rue de la République, 83510 Lorgues', NULL, NULL),
(2, 2, '2026-01-15 11:26:40', 'en_preparation', 729.98, 6.90, 0.00, '45 Avenue du Général de Gaulle, 06000 Nice', NULL, NULL),
(3, 3, '2026-01-15 11:26:40', 'validee', 649.99, 5.90, 0.00, '78 Boulevard Victor Hugo, 13001 Marseille', NULL, NULL),
(4, 4, '2026-01-15 11:26:40', 'preparee', 479.98, 7.50, 0.00, '23 Rue des Lilas, 83000 Toulon', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `historique_stock`
--

CREATE TABLE `historique_stock` (
  `id_historique` int(11) NOT NULL,
  `id_article` int(11) NOT NULL,
  `type_mouvement` enum('entree','sortie') NOT NULL,
  `quantite` int(11) NOT NULL,
  `motif` varchar(100) DEFAULT NULL,
  `date_mouvement` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_user` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `lignes_commande`
--

CREATE TABLE `lignes_commande` (
  `id_ligne` int(11) NOT NULL,
  `id_commande` int(11) NOT NULL,
  `id_article` int(11) NOT NULL,
  `quantite` int(11) NOT NULL DEFAULT 1,
  `prix_unitaire` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `lignes_commande`
--

INSERT INTO `lignes_commande` (`id_ligne`, `id_commande`, `id_article`, `quantite`, `prix_unitaire`) VALUES
(1, 1, 1, 1, 1299.99),
(2, 1, 7, 1, 99.99),
(3, 1, 15, 1, 149.99),
(4, 2, 10, 1, 349.99),
(5, 2, 11, 1, 279.99),
(6, 2, 7, 1, 99.99),
(7, 3, 6, 1, 649.99),
(8, 4, 8, 1, 139.99),
(9, 4, 12, 1, 149.99),
(10, 4, 14, 2, 149.99);

-- --------------------------------------------------------

--
-- Structure de la table `panier`
--

CREATE TABLE `panier` (
  `id_panier` int(11) NOT NULL,
  `id_client` int(11) NOT NULL,
  `id_article` int(11) NOT NULL,
  `quantite` int(11) NOT NULL DEFAULT 1,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `stock`
--

CREATE TABLE `stock` (
  `id_stock` int(11) NOT NULL,
  `id_article` int(11) NOT NULL,
  `quantite_disponible` int(11) NOT NULL DEFAULT 0,
  `seuil_alerte` int(11) NOT NULL DEFAULT 10,
  `date_maj` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `stock`
--

INSERT INTO `stock` (`id_stock`, `id_article`, `quantite_disponible`, `seuil_alerte`, `date_maj`) VALUES
(1, 1, 15, 5, '2026-01-15 11:26:40'),
(2, 2, 8, 5, '2026-01-15 11:26:40'),
(3, 3, 5, 3, '2026-01-15 11:26:40'),
(4, 4, 20, 10, '2026-01-15 11:26:40'),
(5, 5, 12, 10, '2026-01-15 11:26:40'),
(6, 6, 18, 10, '2026-01-15 11:26:40'),
(7, 7, 25, 10, '2026-01-15 11:26:40'),
(8, 8, 30, 15, '2026-01-15 11:26:40'),
(9, 9, 10, 5, '2026-01-15 11:26:40'),
(10, 10, 22, 10, '2026-01-15 11:26:40'),
(11, 11, 28, 10, '2026-01-15 11:26:40'),
(12, 12, 15, 10, '2026-01-15 11:26:40'),
(13, 13, 8, 5, '2026-01-15 11:26:40'),
(14, 14, 40, 15, '2026-01-15 11:26:40'),
(15, 15, 35, 15, '2026-01-15 11:26:40');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('responsable','preparateur','admin') NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  `actif` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id_user`, `username`, `password`, `role`, `nom`, `prenom`, `email`, `date_creation`, `actif`) VALUES
(1, 'responsable1', '123456', 'responsable', 'Dupont', 'Michel', 'responsable@vpc.com', '2026-01-15 11:26:39', 1),
(2, 'preparateur1', '123456', 'preparateur', 'Bernard', 'Jean', 'preparateur@vpc.com', '2026-01-15 11:26:39', 1),
(3, 'admin1', 'admin', 'admin', 'Martin', 'Sophie', 'admin@vpc.com', '2026-01-15 11:26:39', 1);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_articles_stock`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_articles_stock` (
`id_article` int(11)
,`reference` varchar(50)
,`nom` varchar(100)
,`prix` decimal(10,2)
,`nom_categorie` varchar(50)
,`quantite_disponible` int(11)
,`seuil_alerte` int(11)
,`statut_stock` varchar(7)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_commandes_detail`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_commandes_detail` (
`id_commande` int(11)
,`date_commande` timestamp
,`statut` enum('en_attente','validee','en_preparation','preparee','expediee','livree','annulee')
,`montant_total` decimal(10,2)
,`frais_port` decimal(10,2)
,`client` varchar(101)
,`email` varchar(100)
,`telephone` varchar(20)
,`nb_articles` bigint(21)
,`adresse_livraison` varchar(200)
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_articles_stock`
--
DROP TABLE IF EXISTS `v_articles_stock`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_articles_stock`  AS SELECT `a`.`id_article` AS `id_article`, `a`.`reference` AS `reference`, `a`.`nom` AS `nom`, `a`.`prix` AS `prix`, `c`.`nom_categorie` AS `nom_categorie`, `s`.`quantite_disponible` AS `quantite_disponible`, `s`.`seuil_alerte` AS `seuil_alerte`, CASE WHEN `s`.`quantite_disponible` < `s`.`seuil_alerte` THEN 'Alerte' WHEN `s`.`quantite_disponible` = 0 THEN 'Rupture' ELSE 'OK' END AS `statut_stock` FROM ((`articles` `a` left join `stock` `s` on(`a`.`id_article` = `s`.`id_article`)) left join `categories` `c` on(`a`.`id_categorie` = `c`.`id_categorie`)) WHERE `a`.`actif` = 1 ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_commandes_detail`
--
DROP TABLE IF EXISTS `v_commandes_detail`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_commandes_detail`  AS SELECT `cmd`.`id_commande` AS `id_commande`, `cmd`.`date_commande` AS `date_commande`, `cmd`.`statut` AS `statut`, `cmd`.`montant_total` AS `montant_total`, `cmd`.`frais_port` AS `frais_port`, concat(`c`.`prenom`,' ',`c`.`nom`) AS `client`, `c`.`email` AS `email`, `c`.`telephone` AS `telephone`, count(`lc`.`id_ligne`) AS `nb_articles`, `cmd`.`adresse_livraison` AS `adresse_livraison` FROM ((`commandes` `cmd` join `clients` `c` on(`cmd`.`id_client` = `c`.`id_client`)) left join `lignes_commande` `lc` on(`cmd`.`id_commande` = `lc`.`id_commande`)) GROUP BY `cmd`.`id_commande` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id_article`),
  ADD UNIQUE KEY `reference` (`reference`),
  ADD KEY `id_categorie` (`id_categorie`);

--
-- Index pour la table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id_categorie`),
  ADD UNIQUE KEY `nom_categorie` (`nom_categorie`);

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id_client`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD PRIMARY KEY (`id_commande`),
  ADD KEY `id_client` (`id_client`);

--
-- Index pour la table `historique_stock`
--
ALTER TABLE `historique_stock`
  ADD PRIMARY KEY (`id_historique`),
  ADD KEY `id_article` (`id_article`),
  ADD KEY `id_user` (`id_user`);

--
-- Index pour la table `lignes_commande`
--
ALTER TABLE `lignes_commande`
  ADD PRIMARY KEY (`id_ligne`),
  ADD KEY `id_commande` (`id_commande`),
  ADD KEY `id_article` (`id_article`);

--
-- Index pour la table `panier`
--
ALTER TABLE `panier`
  ADD PRIMARY KEY (`id_panier`),
  ADD KEY `id_client` (`id_client`),
  ADD KEY `id_article` (`id_article`);

--
-- Index pour la table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`id_stock`),
  ADD UNIQUE KEY `id_article` (`id_article`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `articles`
--
ALTER TABLE `articles`
  MODIFY `id_article` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `categories`
--
ALTER TABLE `categories`
  MODIFY `id_categorie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `id_client` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `commandes`
--
ALTER TABLE `commandes`
  MODIFY `id_commande` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `historique_stock`
--
ALTER TABLE `historique_stock`
  MODIFY `id_historique` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `lignes_commande`
--
ALTER TABLE `lignes_commande`
  MODIFY `id_ligne` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `panier`
--
ALTER TABLE `panier`
  MODIFY `id_panier` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `stock`
--
ALTER TABLE `stock`
  MODIFY `id_stock` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `articles`
--
ALTER TABLE `articles`
  ADD CONSTRAINT `articles_ibfk_1` FOREIGN KEY (`id_categorie`) REFERENCES `categories` (`id_categorie`);

--
-- Contraintes pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD CONSTRAINT `commandes_ibfk_1` FOREIGN KEY (`id_client`) REFERENCES `clients` (`id_client`);

--
-- Contraintes pour la table `historique_stock`
--
ALTER TABLE `historique_stock`
  ADD CONSTRAINT `historique_stock_ibfk_1` FOREIGN KEY (`id_article`) REFERENCES `articles` (`id_article`),
  ADD CONSTRAINT `historique_stock_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`);

--
-- Contraintes pour la table `lignes_commande`
--
ALTER TABLE `lignes_commande`
  ADD CONSTRAINT `lignes_commande_ibfk_1` FOREIGN KEY (`id_commande`) REFERENCES `commandes` (`id_commande`) ON DELETE CASCADE,
  ADD CONSTRAINT `lignes_commande_ibfk_2` FOREIGN KEY (`id_article`) REFERENCES `articles` (`id_article`);

--
-- Contraintes pour la table `panier`
--
ALTER TABLE `panier`
  ADD CONSTRAINT `panier_ibfk_1` FOREIGN KEY (`id_client`) REFERENCES `clients` (`id_client`) ON DELETE CASCADE,
  ADD CONSTRAINT `panier_ibfk_2` FOREIGN KEY (`id_article`) REFERENCES `articles` (`id_article`);

--
-- Contraintes pour la table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`id_article`) REFERENCES `articles` (`id_article`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
