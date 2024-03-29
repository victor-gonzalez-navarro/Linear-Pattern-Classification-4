%% CLP
% Práctica 5, BD: SPAM, Classifier: SV
% April 2016, MC
clear
close all
clc

i_plot=1;                               % 1 dibuja BD
i_lineal=1;                             % Linear Classifier
i_gauss=1;                              % Gaussian Kernel Classifier

%% Loading SPAM Database
% load dataspam.txt -ascii
load dataspam
Labs=dataspam(:,end);
N_feat=size(dataspam,2)-1;
X=dataspam(:,1:57);
N_datos=length(Labs);

%% Scatter plot
if i_plot==1
    figure('name','Scatter PLOT of signs')
    X2=X(:,49:54);
    gplotmatrix(X2,X2,Labs)
    zoom on
    clear X2
end
drawnow
clear i_plot

%% Cuantificación binaria de características
X=X(:,1:54);
A=find(X>0);
X(A)=ones(size(A));

%% Generación BD Train (60 %), Cross Validation (20%) y BD Test (20%)
%Aleatorización orden de los vectores
indexperm=randperm(N_datos);
X=X(indexperm,:);
Labs=Labs(indexperm);

% Identificación de un vector para cálculo de probabilidad (sección 3.3)
V_analisis=X(N_datos,:);
Lab_analisis=Labs(N_datos)
N_datos=N_datos-1;
X=X(1:N_datos,:);
Labs=Labs(1:N_datos);

% Generación BD Train, BD Validation, BD Test
N_train=round(0.6*N_datos);
N_val=round(0.8*N_datos)-N_train;
N_test=N_datos-N_train-N_val;

% Train
X_train=X(1:N_train,:);
Labs_train=Labs(1:N_train);

%Val: Validation
X_val=X(N_train+1:N_train+N_val,:);
Labs_val=Labs(N_train+1:N_train+N_val);

% Test
X_test=X(N_train+N_val+1:N_datos,:);
Labs_test=Labs(N_train+N_val+1:N_datos);

clear indexperm
%% Clasificador lineal
if i_lineal ==1
    P = 0.1;
    Linear_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P);
    fprintf(1,'\n Clasificador SVM lineal\n')
    
    Linear_out = predict(Linear_model, X_train);
    Err_train=sum(Linear_out~=Labs_train)/length(Labs_train);
    fprintf(1,'error train = %g   \n', Err_train)
    
    Linear_out = predict(Linear_model, X_val); 
    Err_val=sum(Linear_out~=Labs_val)/length(Labs_val);
    fprintf(1,'error validation = %g   \n', Err_val)
    
    Linear_out = predict(Linear_model, X_test);    
    Err_test=sum(Linear_out~=Labs_test)/length(Labs_test);
    fprintf(1,'error test = %g   \n', Err_test)
    fprintf(1,'\n  \n  ')
    % Test confusion matrix
    CM_Linear_test=confusionmat(Labs_test,Linear_out)
    clear Err_train Err_test Linear_out
end
clear i_lineal

%% Clasificador kernel gaussiano
if i_gauss ==1
    P = 0.1;
    h=1;
    Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P,...
        'KernelFunction','RBF','KernelScale',h);
    fprintf(1,'\n Clasificador Kernel Gaussiano\n')
    
    Gauss_out = predict(Gauss_model, X_train);
    Err_train=sum(Gauss_out~=Labs_train)/length(Labs_train);
    fprintf(1,'error train = %g   \n', Err_train)
    
    Gauss_out = predict(Gauss_model, X_val);
    Err_val=sum(Gauss_out~=Labs_val)/length(Labs_val);
    fprintf(1,'error val = %g   \n', Err_val)
    
    Gauss_out = predict(Gauss_model, X_test);
    Err_test=sum(Gauss_out~=Labs_test)/length(Labs_test);
    fprintf(1,'error test = %g   \n', Err_test)
    fprintf(1,'\n  \n  ')
    % Test confusion matrix
    CM_Gauss_test=confusionmat(Labs_test,Gauss_out)
    clear Err_train Err_test Gauss_out
end
clear i_gauss

%% Clasificador kernel gaussiano con varios P y h

if i_gauss ==1
    P=0.01:0.1:5;
    H=[1 2.5 10 25 100];
    [X,Y] = meshgrid(P,H);
    Z_test = zeros(length(P),length(H));
    Z_val = zeros(length(P),length(H));
    for i=1:length(P)
        for j=1:length(H)
            Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P(i),...
        'KernelFunction','RBF','KernelScale',H(j));
            Gauss_out = predict(Gauss_model, X_train);
            err_mat_t=sum(Gauss_out~=Labs_train)/length(Labs_train);
            Gauss_out = predict(Gauss_model, X_val);
            err_mat_v=sum(Gauss_out~=Labs_val)/length(Labs_val);
            Z_test(i,j) = err_mat_t;
            Z_val(i,j) = err_mat_v;
        end
    end
    clear Err_train Err_test Gauss_out
end

figure;
title('Z_test');
mesh(X,Y,Z_test');
figure;
title('Z_val');
mesh(X,Y,Z_val');

%% Buscamos mejor P y H

[P_best_val,P_best] = min(Z_val);
[H_best_val,H_best] = min(P_best_val);
P_best = P_best(H_best);
error_best = Z_val(P_best,H_best);

P(P_best)
H(H_best)
error_best

%% Gaussiano optimo

%% Clasificador kernel gaussiano
if i_gauss ==1
    P = 2.41;
    h=2.5;
    Gauss_model = fitcsvm(X_train, Labs_train, 'BoxConstraint',P,...
        'KernelFunction','RBF','KernelScale',h);
    fprintf(1,'\n Clasificador Kernel Gaussiano\n')
    
    Gauss_out = predict(Gauss_model, X_train);
    Err_train=sum(Gauss_out~=Labs_train)/length(Labs_train);
    fprintf(1,'error train = %g   \n', Err_train)
    
    Gauss_out = predict(Gauss_model, X_val);
    Err_val=sum(Gauss_out~=Labs_val)/length(Labs_val);
    fprintf(1,'error val = %g   \n', Err_val)
    
    Gauss_out = predict(Gauss_model, X_test);
    Err_test=sum(Gauss_out~=Labs_test)/length(Labs_test);
    fprintf(1,'error test = %g   \n', Err_test)
    fprintf(1,'\n  \n  ')
    % Test confusion matrix
    CM_Gauss_test=confusionmat(Labs_test,Gauss_out);
    clear Err_train Err_test Gauss_out
end

All_no_spam_num = sum(CM_Gauss_test(:,1));
All_spam_num = sum(CM_Gauss_test(:,2));

Class_no_spam = sum(CM_Gauss_test(1,:));
Class_spam = sum(CM_Gauss_test(2,:));

P = CM_Gauss_test(2,2) / Class_spam;
S = CM_Gauss_test(2,2) / All_spam_num;
E_s = sum(diag(CM_Gauss_test)) / sum(sum(CM_Gauss_test));

E_c = (CM_Gauss_test(2,1) + CM_Gauss_test(1,2))/(sum(sum(CM_Gauss_test)));
A = 1 - Ec;
