KanTask

#Jak uruchomic projekt?

git clone <URL_REPOZYTORIUM>
cd KanTask
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver


#Dodatkowo wymagane połączenie do bazy danych 31.183.16.15, zaptaj o dostep jesli nie masz ;)