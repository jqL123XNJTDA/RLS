close all;clear all;clc;

%% 产生测试信号
fs = 1;
f0 = 0.02;
n = 1000;
t = (0:n-1)'/fs;
xs = cos(2*pi*f0*t);
SNR = 10;
ws = awgn(xs, SNR, 'measured');


%% main
w = 0.1;
delta = 2;
[d,error_vect,estimate_h] = RLS_func(w,xs,ws,delta);%
figure
subplot(211)
plot(d)
grid on;ylabel('幅值');xlabel('时间');
ylim([-1.5 1.5]);title('RLS滤波器输出信号');
subplot(212)
plot(ws)
grid on;ylabel('幅值');xlabel('时间');title('RLS滤波器输入信号');
ylim([-1.5 1.5]);


%% RLS函数  返回滤波后的信号 d、误差向量 error_vect 和估计的滤波器系数 estimate_h
function [d,error_vect,estimate_h] = RLS_func(w,xs,ws,delta)
% 参数初始化
L = 32; %滤波器长度
n = 1000;
X_n = ws;
d_n = xs;
P_M = delta*eye(L,L);
estimate_h = zeros(L,1);
estimate_h(1,:) = 1;
error_vect = zeros(n-L,1);

    for i =1 : n-L
        x_vect = X_n(i:i+L-1);%32*1
        mu = x_vect.' * P_M * conj(x_vect);%1*1
        K = P_M * conj(x_vect) / (0.9+ mu);%32*1
        P_M = (P_M - K * x_vect.' * P_M)/0.9%32*32
        estimate_d = x_vect.' * estimate_h;%1*1
        error = d_n(i) - estimate_d;
        error_vect(i,:) = error;
        estimate_h = estimate_h + K * error;
    end
    d = inf * ones(size(X_n));
    for i = 1:n-L
        x_vect = X_n(i:i+L-1);
        d(i)  = estimate_h.' * x_vect;
    end
end
