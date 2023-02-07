clc();
clear all();

fs = 1000; 
t = 0 : 1/ fs :1; 
f = 100; 


x = sin(2*pi * f * t);

subplot(4,1,1)
plot (t,x,'r', 'LineWidth',2); 

xlabel("Time")
ylabel("Amplitude")
title("Input"); 
grid on; 


x_rf = raylrnd(x);% adds rayleigh Noise to the signal
% plot the noisy signal
subplot(4,1,3),plot(t, x_rf, 'b', 'Linewidth', 2);
xlabel('Time');
ylabel('Amplitude');
title('Rayleigh Output Signal');
grid on;