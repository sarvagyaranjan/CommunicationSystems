clc();
clear all();

fs = 1000; 
t = 0 : 1/ fs :1; 
f = 100; 

x = sin(2*pi * f * t);
subplot(4,1,1)
plot(t,x,'r', 'LineWidth', 2); 
xlabel('Time');
ylabel('Amplitude');
title("Input Signal")

x_rc = raylrnd(x) .* raylrnd(x);% adds rayleigh Noise to the signal
% plot the noisy signal
subplot(4,1,2),plot(t, x_rc, 'b', 'Linewidth', 2);
xlabel('Time');
ylabel('Amplitude');
title('Rician Output Signal');
grid on;
