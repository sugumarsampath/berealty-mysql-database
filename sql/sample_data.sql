-- ============================================================
-- Berealty sample data — realistic Berlin scenarios
-- ============================================================
USE berealty;

INSERT INTO agents (first_name, last_name, email, phone, hire_date, commission_rate) VALUES
('Lena','Hoffmann','lena.hoffmann@berealty.de','+49 30 5551001','2021-03-15',0.035),
('Jonas','Weber','jonas.weber@berealty.de','+49 30 5551002','2020-07-01',0.030),
('Aylin','Kaya','aylin.kaya@berealty.de','+49 30 5551003','2022-01-10',0.032),
('Markus','Schneider','markus.schneider@berealty.de','+49 30 5551004','2019-11-20',0.040),
('Sofia','Rossi','sofia.rossi@berealty.de','+49 30 5551005','2023-05-02',0.028),
('David','Nowak','david.nowak@berealty.de','+49 30 5551006','2024-02-19',0.030);

INSERT INTO clients (first_name, last_name, email, phone, client_type, registered_date) VALUES
('Anna','Becker','anna.becker@mail.de','+49 171 2000001','buyer','2025-01-12'),
('Tom','Fischer','tom.fischer@mail.de','+49 171 2000002','buyer','2025-02-03'),
('Elif','Demir','elif.demir@mail.de','+49 171 2000003','tenant','2025-02-21'),
('Paul','Wagner','paul.wagner@mail.de','+49 171 2000004','seller','2025-03-05'),
('Marta','Kowalska','marta.kowalska@mail.de','+49 171 2000005','tenant','2025-03-18'),
('Felix','Braun','felix.braun@mail.de','+49 171 2000006','buyer','2025-04-02'),
('Yuki','Tanaka','yuki.tanaka@mail.de','+49 171 2000007','tenant','2025-04-25'),
('Clara','Zimmermann','clara.zimmermann@mail.de','+49 171 2000008','landlord','2025-05-10'),
('Omar','Haddad','omar.haddad@mail.de','+49 171 2000009','buyer','2025-06-01'),
('Julia','Krüger','julia.krueger@mail.de','+49 171 2000010','buyer','2025-06-15'),
('Nils','Petersen','nils.petersen@mail.de','+49 171 2000011','tenant','2025-07-08'),
('Sara','Lindberg','sara.lindberg@mail.de','+49 171 2000012','buyer','2025-08-19');

INSERT INTO properties (agent_id, title, property_type, district, address, size_sqm, rooms, listing_type, price, status, listed_date) VALUES
(1,'Bright 2-room flat near Mauerpark','apartment','Prenzlauer Berg','Oderberger Str. 12',58.0,2,'sale',420000.00,'available','2025-01-20'),
(1,'Renovated Altbau with balcony','apartment','Charlottenburg','Kantstr. 45',86.5,3,'sale',695000.00,'available','2025-02-11'),
(2,'Modern studio, canal view','apartment','Kreuzberg','Paul-Lincke-Ufer 3',34.0,1,'rent',1150.00,'available','2025-02-25'),
(2,'Family house with garden','house','Zehlendorf','Ahornweg 8',142.0,5,'sale',985000.00,'available','2025-03-07'),
(3,'Loft office in converted factory','office','Friedrichshain','Revaler Str. 20',210.0,NULL,'rent',4200.00,'available','2025-03-15'),
(3,'Quiet 3-room flat, courtyard','apartment','Neukölln','Weserstr. 51',74.0,3,'rent',1480.00,'available','2025-04-01'),
(4,'Retail unit on high street','retail','Mitte','Friedrichstr. 88',95.0,NULL,'rent',6800.00,'available','2025-04-12'),
(4,'Penthouse with roof terrace','apartment','Mitte','Torstr. 140',118.0,4,'sale',1250000.00,'available','2025-04-28'),
(5,'Compact 1-room flat for commuters','apartment','Schöneberg','Hauptstr. 27',29.5,1,'rent',890.00,'available','2025-05-05'),
(5,'Suburban duplex, newly built','house','Spandau','Wasserstadt 4',126.0,4,'sale',640000.00,'available','2025-05-22'),
(6,'Co-working floor, open plan','office','Kreuzberg','Ritterstr. 11',330.0,NULL,'rent',7900.00,'available','2025-06-02'),
(1,'Sunny 4-room family flat','apartment','Prenzlauer Berg','Stargarder Str. 6',102.0,4,'sale',870000.00,'available','2025-06-18'),
(2,'Garden-level 2-room flat','apartment','Neukölln','Sonnenallee 190',55.0,2,'rent',1190.00,'available','2025-07-01'),
(3,'Corner shop with storage','retail','Wedding','Müllerstr. 63',72.0,NULL,'rent',2350.00,'available','2025-07-20'),
(6,'Classic Altbau, first occupancy','apartment','Charlottenburg','Mommsenstr. 19',91.0,3,'sale',760000.00,'available','2025-08-04');

INSERT INTO viewings (property_id, client_id, agent_id, viewing_date, feedback) VALUES
(1,1,1,'2025-02-01 10:00:00','Liked the location, price slightly high'),
(1,6,1,'2025-02-03 14:30:00','Very interested'),
(2,2,1,'2025-03-01 11:00:00','Wants second viewing'),
(3,3,2,'2025-03-05 16:00:00','Ready to apply'),
(4,9,2,'2025-03-20 10:30:00','Garden too small'),
(5,8,3,'2025-04-02 09:00:00','Suits the startup team'),
(6,5,3,'2025-04-10 17:00:00','Applying this week'),
(7,8,4,'2025-04-25 12:00:00','Negotiating rent'),
(8,10,4,'2025-05-10 15:00:00','Loved the terrace'),
(9,7,5,'2025-05-15 09:30:00','Perfect size'),
(10,2,5,'2025-06-05 13:00:00','Comparing with city options'),
(12,6,1,'2025-07-02 10:00:00','Family very keen'),
(13,11,2,'2025-07-12 18:00:00','Good value'),
(15,12,6,'2025-08-20 11:30:00','Considering an offer');

-- Transactions: triggers compute commission and flip property status
INSERT INTO transactions (property_id, client_id, agent_id, transaction_type, transaction_date, amount) VALUES
(3, 3, 2,'rental','2025-03-14',1150.00),
(6, 5, 3,'rental','2025-04-18',1480.00),
(1, 6, 1,'sale',  '2025-05-06',408000.00),
(5, 8, 3,'rental','2025-05-09',4200.00),
(9, 7, 5,'rental','2025-06-11',890.00),
(4, 9, 2,'sale',  '2025-07-03',952000.00),
(7, 8, 4,'rental','2025-07-21',6500.00),
(13,11,2,'rental','2025-08-01',1190.00),
(8,10, 4,'sale',  '2025-09-15',1215000.00),
(12, 6,1,'sale',  '2025-10-10',855000.00),
(10, 2,5,'sale',  '2025-12-12',628000.00),
(11, 8,6,'rental','2026-02-14',7700.00);
