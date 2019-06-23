# -*- coding: latin-1 -*-
import cv2
import os
import numpy as np
import pickle
from PIL import Image

# Cria uma IA baseada no reconhecimento facil do algoritmo LBPH
AI_security_recognizer = cv2.face.LBPHFaceRecognizer_create() 

# Importando mesmo Haar Cascade
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_alt2.xml')
eyes_cascade = cv2.CascadeClassifier('haarcascade_eye.xml')

# Serve para guardar o id que está sendo acessado
current_id = 0

# Dicionário para guardar os endereços associados
label_ids = {}

y_labels = []
x_train = []

# Guarda o caminho onde o arquivo faces_train.py está salvo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Salva o diretório das imagens baseado no diretório 
image_dir = os.path.join(BASE_DIR, "Images")

# Mapeia diretório fonte, diretórios e arquivos no diretório das imagens 
for root, dirs, files in os.walk(image_dir):
    for file in files:
        if file.endswith("png") or file.endswith("jpg") or file.endswith("jpeg"):
            path = os.path.join(root, file)

            # Pega o nome do arquivo 
            label = os.path.basename(os.path.dirname(path)).replace(" ", "-").lower()

            # Printa a pasta onde o arquivo está e o caminho do arquivo a ser acessado
            # print(label, path)

            # Se a pasta associada não foi acessada, associa a pasta a um id e incrementa o id de iteração
            if not label in label_ids:
                label_ids[label] = current_id
                current_id += 1

            # print(label_ids)

            # Variável extra para guardar o id atual sendo acessado
            id_ = label_ids[label] 

            # Algum número
            # y_labels.append(path)

            # Verifica a imagem, transforma em um array NUMPY, cinza
            # x_train.append(path)

            # Abre uma imagem no path e converte para grayscale
            pil_image = Image.open(path).convert("L") 

            # Resolução do meu computador
            resolution = (640, 480)

            # Redimensiona imagem para ficar compatível com Webcam
            final_image = pil_image.resize(resolution, Image.ANTIALIAS)

            # Cria um array em numpy de pil_image para 
            image_array = np.array(pil_image, "uint8")

            # Printa o array da imagem
            # print(image_array)

            #  Mesmo procedimento do faces_recognition.py          
            faces = face_cascade.detectMultiScale(image_array, scaleFactor=1.5, minNeighbors=5)
            
            for(x, y, w, h) in faces:
                region_of_interest = image_array[y:y+h, x:x+w]
                # x_train vai receber os valores em UTF8 do rosto
                x_train.append(region_of_interest)
                # y_labels vai receber o ID de cada pasta
                y_labels.append(id_)

    #print(y_labels)
    #print(x_train)

with open("labels.pickle", 'wb') as f:
    # Associa os label_ids a um arquivo f
    pickle.dump(label_ids, f)

# Treina a IA baseado nos pixeis passados (em numpy array) e convertendo o y_labels em numpy arrays
AI_security_recognizer.train(x_train, np.array(y_labels))
AI_security_recognizer.save("trainer.yml")


