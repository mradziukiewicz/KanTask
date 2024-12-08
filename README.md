KanTask

#Jak uruchomic projekt?

git clone <URL_REPOZYTORIUM>
cd KanTask
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver