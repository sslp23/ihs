# -*- coding: latin-1 -*-

# Bibliotecas úteis para o programa
import numpy as np
import cv2
import pickle
from collections import Counter
import threading
import sys
import time


CONFIDENCE_RATIO = 45

def most_frequent(List):
    occurence_count = Counter(List)
    return occurence_count.most_common(1)[0][0]


def exit_program(List):
    print("Bem vindo, ", labels[most_frequent(List)], "!")
    sys.exit(0)

begin = time.time()
frequency = []

labels = {}
with open("labels.pickle", 'rb') as f:
    og_labels = pickle.load(f)
    labels = {v:k for k, v in og_labels.items()}

# Carrega a Cascade para a detecção de rostos 
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

SECURITY_RECOGNIZER = cv2.face.LBPHFaceRecognizer_create()
SECURITY_RECOGNIZER.read("trainer.yml")

# Inicia a captura de vídeo
cap = cv2.VideoCapture(0)


while(True):
    end = time.time()
    # Passa para ret e frame os valores que estão sendo lidos pela WebCam
    ret, frame = cap.read()

    # Passa um filtro cinza para usar pelo Cascade para a detecção
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Método para detectar os rostos
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    # Coordenadas do retângulo que circunda a face detectada
    for(x, y, w, h) in faces:
        # Printa as coordenadas 
        # print(x, y, w, h)
	
        # Região de interesse cinza que a cascade detecta
        region_of_interest_gray = gray[y:y+h, x:x+w]

        # Região de interesse colorida que a cascade detecta
        region_of_interest_colored =  frame[y:y+h, x:x+w]

        # 
        id_, confidence = SECURITY_RECOGNIZER.predict(region_of_interest_gray)

        if(confidence >= CONFIDENCE_RATIO):
            print(confidence)
            print(id_)
            print(labels[id_])
            frequency.append(id_)
            font = cv2.FONT_HERSHEY_SIMPLEX
            name = labels[id_]
            cv2.putText(frame, name, (x - 20, y - 10), font, 1, (255, 255, 255), 2)
            
        # Parâmetros para salvar a imagem lida na pasta
        img_item = "my-image.png"
        cv2.imwrite(img_item, region_of_interest_gray)

        # Parâmetros de cor em BGR 
        blue_color =  (255, 0 , 0)

        #Define a largura da linha do retângulo
        rectangle_thickness = 2

        # Parâmetros para mapear o quadrado na posição do rosto
        end_cord_x = x + w
        end_cord_y = y + h

        # Desenha um quadrado na posição do rosto
        cv2.rectangle(frame, (x, y), (end_cord_x, end_cord_y), (255, 0 , 200), rectangle_thickness)

    # Printa a imagem que está sendo lida para a Webcam
    cv2.imshow('Look, a ginger!', frame) # Mudar nome da janela

    # Aguarda o comando para finalizar o programa
    if cv2.waitKey(20) & 0xFF == ord('q') or (end - begin >= 10.0):
        break
    
print("Bem vindo, " + labels[most_frequent(frequency)] + "!")

# Finaliza a gravação de vídeo 
cap.release()

# Fecha todas as janelas e finaliza o programa logo após
cv2.destroyAllWindows()
