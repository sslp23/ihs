# -*- coding: latin-1 -*-

# Bibliotecas úteis para o programa
import numpy as np
import cv2

# Carrega a Cascade para a detecção de rostos 
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_alt2.xml')

# Inicia a captura de vídeo
cap = cv2.VideoCapture(0)

while(True):
    # Passa para ret e frame os valores que estão sendo lidos pela WebCam
    ret, frame = cap.read()

    # Passa um filtro cinza para usar pelo Cascade para a detecção
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Método para detectar os rostos
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.5, minNeighbors=5)

    # Coordenadas do retângulo que circunda a face detectada
    for(x, y, w, h) in faces:
        # Printa as coordenadas 
        print(x, y, w, h)

        # Região de interesse cinza que a cascade detecta
        region_of_interest_gray = gray[y:y+h, x:x+w]

        # Região de interesse colorida que a cascade detecta
        region_of_interest_colored =  frame[y:y+h, x:x+w]

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
    cv2.imshow('Look, a nigger!', frame) # Mudar nome da janela

    # Aguarda o comando para finalizar o programa
    if cv2.waitKey(20) & 0xFF == ord('q'):
        break
    
# Finaliza a gravação de vídeo 
cap.release()

# Fecha todas as janelas e finaliza o programa logo após
cv2.destroyAllWindows()