Pour diffuser des offres sur la plateforme "[mon stage de 3e](https://www.monstagedetroisieme.fr/)", une API sera mise à disposition pour :

* les associations
* les collectivités
* les ministères

L'API sera :

* construite sur le format "REST"
* inspiré du standard [jsonapi](https://jsonapi.org)
* avec le point d'entrée ```baseUrl```:
  * En pré production : https://v2-test.monstagedetroisieme.fr/api
  * En production : https://monstagedetroisieme.fr/api

Les services web suivant seront mis à disposition :

* POST [/internship_offers](#ref-create-internship-offer) : Pour ajouter une offre de stage sur Mon stage de 3e
* PATCH [/internship_offers/{remote_id}](#ref-modify-internship-offer) : Pour modifier l'offre de stage avec l'identifiant ```remote_id``` sur Mon stage de 3e
* DELETE [/internship_offers/{remote_id}](#ref-destroy-internship-offer) : Pour supprimer une offre de stage sur Mon stage de 3e


# Authentification

*Les APIs sont ouvertes uniquement aux acteurs concernés.*

**Merci d'effectuer une demande par mail** ([support](mailto:martin.fourcade@beta.gouv.fr)) pour créer un compte API.

Une fois le compte créé, le token d'API pourra être récupéré via notre interface web. Il est différent selon l'environnement de test ou production.

L'authentification se fait par token via le header HTTP : ```Authorization: Bearer #{token} ```

Ce token devra être présent à chaque requête.

# Gestion d'erreurs
Les erreurs de requête seront signalées via un code HTTP > 400.

Sur chaque requête, on pourra avoir les erreurs suivantes :

- 400, Bad Request : Paramètres de requête mal renseignés. Exemple : Secteur non indiqué dans la création d'une offres
- 401, Unauthorized : Token invalide
- 403, Forbidden : Pas le droit d'effectuer cette requête. Exemple : Modification d'une offre qui ne vous appartient pas
- 422, Unprocessable Entity. Payload incorrect, impossible de traiter la requête

- 500, Internal Server Error : Service indisponible

En plus de ses erreurs transverses, les erreurs spécifiques à un appel seront détaillées pour chacun d'entre eux.


# Endpoints

### <a name="ref-create-internship-offer"></a>
## Création d'une offre


**url** : https://monstagedetroisieme.fr/api/internship_offers

**method** : POST

*Paramètres de body :*

* **internship_offer.title** *(string, required)*
* **internship_offer.description** *(text, required *<= 500 caractères)
* **internship_offer.employer_name** *(string, required)*
* **internship_offer.employer_description** *(string, required *<= 275 caractères)
* **internship_offer.employer_website** *(string, optional)*
* **internship_offer.coordinates** *(object/geography, required)* : { latitude: 1, longitude: 1 }
* **internship_offer.street** *(text, optional)*
* **internship_offer.zipcode** *(string, required)*
* **internship_offer.city** *(string, required)*
* **internship_offer.sector_uuid** *(integer, required)*
* **internship_offer.weeks** (array[datatype:week(year, week_number), datatype:week(year, week_number), ...], optional) : si ce champs n'est pas rempli, le stage sera automatiquement disponible toute l'année
* **remote_id** *(string, required)*: l'identifiant unique du coté operateur|collectivité|association
* **permalink** *(url, required)*

### Exemple curl

```
curl -H "Authorization: Bearer foobarbaz" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X POST \
     -d '{"internship_offer": {"title":"Mon offre de stage", "description": "Description..."}}' \
     -vvv \
     https://monstagedetroisieme.fr/api/internship_offers
```

### Erreurs

- 409, Conflict. Une offre avec le même ```remote_id``` existe déjà

### <a name="ref-modify-internship-offer"></a>
## Modification d'une offre


**url** : https://monstagedetroisieme.fr/api/internship_offers/#{remote_id}

**method** : PATCH

*Paramètres d'url* :

* **remote_id** *(string, required)*
* **internship_offer.title** *(string)*
* **internship_offer.description** *(text,  <= 500 caractères)*
* **internship_offer.employer_name** *(string)*
* **internship_offer.employer_description** *(string, <= 275 caractères)*
* **internship_offer.employer_website** *(string)*
* **internship_offer.coordinates** *(object/geography)* : { latitude: 1, longitude: 1 }
* **internship_offer.street** *(text)*
* **internship_offer.zipcode** *(string)*
* **internship_offer.city** *(string)*
* **internship_offer.sector_uuid** *(integer)*
* **internship_offer.weeks** (array[datatype:week(year, week_number), datatype:week(year, week_number), ...], optional) : si ce champs n'est pas rempli, le stage sera automatiquement disponible toute l'année
* **permalink** *(url)*

### Exemple curl

```
curl -H "Authorization: Bearer foobarbaz" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X PATCH \
     -d '{"internship_offer": {"title":"Mon offre de stage", "description": "Description..."}}' \
     -vvv \
     https://monstagedetroisieme.fr/api/internship_offers/#{remote_id}
```

### Erreurs

- 404, Not Found. Aucune offre n'a été trouvée avec le ```remote_id``` spécifié
- 422, Unprocessable Entity. Aucun paramètre n'a été spécifié pour la modification

### <a name="ref-destroy-internship-offer"></a>
## Suppression d'une offre
**url** : https://monstagedetroisieme.fr/api/internship_offers/#{remote_id}

**method** : DELETE

*Paramètres d'url* :

* **remote_id** *(string, required)*

### Exemple curl

```
curl -H "Authorization: Bearer foobarbaz" \
     -H "Accept: application/json" \
     -X DELETE \
     -vvv \
     https://monstagedetroisieme.fr/api/internship_offers/#{job_irl_id|vvmt_id|myfuture_id|provider_id...}
```

### Erreurs

- 404, Not Found. Aucune offre n'a été trouvée avec le ```remote_id``` spécifié

# Structures de données et référentiels

## Les offres

```
{
  internship_offer: {
    title : Titre de l’offre de stage
    description : Description de l'offre de stage

    employer_name : Nom de l’entreprise proposant le stage
    employer_description : Description de l’entreprise proposant le stage
    employer_website : Lien web vers le site de l’entreprise proposant le stage

    coordinates : Coordonnées géographique du lieu du stage
    street : Nom de la rue ou se déroule le stage
    zipcode  : Code postal ou se déroule le stage
    city : Nom de la ville où se déroule le stage

    sector_uuid : Identifiant unique du secteurs, voir référentiel *(1)
    weeks : Liste des semaines pendant lequel celui ci est accessible voir référentiel *(2)

    remote_id: l'identifiant unique du coté operateur|collectivité|association
    permalink: lien de redirection pour renvoyer sur le site unique du coté operateur|collectivité|association
  }
}
```


### <a name="ref-weeks"></a>
## Semaines
Les stages se faisant sur des cycles hebdomadaires de travail (du lundi au vendredi), cette information est codifiée selon la [norme ISO 8601 ](https://fr.wikipedia.org/wiki/Num%C3%A9rotation_ISO_des_semaines).

Exemple : 2019-W35 correspondant à :
* L'année : 2019
* Le numéro de semaine : 35, du 26 août au 1er septembre

Exemple de ce que nous attendons dans nos API :

```
internship_offer.weeks: ["2019-W1", "2019-W3", "2019-W5"]
```

### <a name="ref-sectors"></a>
## Secteurs d'activité

L'API attend en paramètre obligatoire un secteur d'activité associé à une offre. Voici la *liste* ainsi que leurs **identifiants uniques**.

* *Mode*: **b7564ac4-e184-41c4-a7a9-57233a9d244a**
* *Banque et assurance*: **6a8f813b-c338-4d4f-a4cd-99a28748b57d**
* *Audiovisuel*: **4b6427b1-b289-486d-b7ea-f33134995a99**
* *Communication*: **63d73fd3-9ca6-4838-95aa-9901896be99c**
* *Édition, librairie, bibliothèque*: **27c1d368-0846-4038-903f-d63b989e0fe4**
* *Traduction, interprétation*: **1123edde-0d77-498a-85c5-2ab3d81b3cd8**
* *Bâtiment et travaux publics (BTP)*: **ab69287d-273a-4626-b645-d98f567b22ba**
* *Comptabilité, gestion, ressources humaines*: **bfb24e1c-aebc-4451-bb4b-569ab71a814d**
* *Droit et justice*: **1711c7c8-89dc-48dd-9ae9-22bde1bd281b**
* *Enseignement*: **76f3a155-e592-4bb9-8512-358a7d9db313**
* *Recherche*: **c5db692a-2a17-403c-8151-1b3cd7dc48ba**
* *Énergie*: **af7e191a-7065-403e-844d-197e7e1e8bdb**
* *Environnement*: **1bbc6281-805e-4045-b85b-65a1479a865d**
* *Logistique et transport*: **19ccd244-5fac-4ad9-8513-7488d0980f4c**
* *Hôtellerie, restauration*: **92e5ad0c-6e30-43a4-8158-818236d01390**
* *Tourisme*: **dd9d626b-735a-4139-87b8-8c67990b97ba**
* *Agroéquipement*: **0b91687a-f3cc-4cd1-bfb5-b9f03994b1bd**
* *Automobile*: **f3733e9c-f33c-4c33-9903-baf9c8e2d2fb**
* *Construction aéronautique, ferroviaire et navale*: **ee0e9e5c-f19e-4be8-9399-2cff4f4e5ca5**
* *Électronique*: **1ce6aa62-6d91-41e5-9135-ce97e7c94a46**
* *Industrie alimentaire*: **95776212-ddd1-466e-ba5b-089f4e2f11ac**
* *Industrie chimique*: **4974df57-0111-492d-ab60-3bfdad10733d**
* *Maintenance*: **0f51b2d6-91da-4543-a0aa-d49a7be3d249**
* *Mécanique*: **4ee8bd54-7b5b-4ae9-9603-78f303d5aea8**
* *Verre, béton, céramique*: **463578f1-b371-4466-a13f-b0e99f783391**
* *Informatique et réseaux*: **bfd92448-5eae-4d99-ae2c-67fffc8fec69**
* *Jeu vidéo*: **be4bab4d-09ed-4205-bca1-1047da0500f8**
* *Commerce et distribution*: **ae267ff2-76d5-460a-9a41-3b820c392149**
* *Marketing, publicité*: **811621f0-e2d1-4c32-a406-5b45979d7c6d**
* *Médical*: **1aae3b41-1394-4109-83cf-17214e1aefdd**
* *Paramédical*: **89946839-8e18-4087-b48d-e6ee5f7d8480**
* *Social*: **d5a7ec0f-5f9c-44cb-add0-66465b4e7d3c**
* *Sport*: **01d06ada-55be-4ebf-8ad2-2666e7a7f521**
* *Agriculture*: **76de34d3-b524-456d-bc91-92e133cdab2b**
* *Filiere bois*: **aa658f28-a9ac-4a29-976f-a528c994f37a**
* *Architecture, urbanisme et paysage*: **1ee1b11c-97ca-4b7e-a6fb-afe404f24954**
* *Armée - Défense*: **4c0e0937-d7af-4b1c-998c-c1b1d628e3a3**
* *Sécurité*: **ec4ce411-f8fd-4690-b51f-3290ffd069e0**
* *Art et design*: **c1f72076-43fb-44ae-a811-d55eccf15c08**
* *Artisanat d'art*: **1ce60ecc-273d-4c73-9b1a-2f5ee14e1bc6**
* *Arts du spectacle*: **055b7580-c979-480f-a026-e94c8b8dc46e**
* *Culture et patrimoine*: **c76e6364-7257-473c-89aa-c951141810ce**

Exemple de ce que nous attendons donc un uuid dans nos API :

```
internship_offer.sector_uuid: "c76e6364-7257-473c-89aa-c951141810ce"
```