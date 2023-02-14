%clear; %clear all stored variables 
N=100; %number of data bits 
noiseVariance = 0.5; %Noise variance of AWGN channel 
data=randn(1,N)>=0; %Generate uniformly distributed random data 
Rb=1e3; %bit rate 
amplitude=1; % Amplitude of NRZ data 
[time,nrzData,Fs]=NRZ_Encoder(data,Rb,amplitude,'Unipolar'); 
Tb=1/Rb; 
subplot(4,2,1); 
stem(data); 
xlabel('Samples'); 
ylabel('Amplitude'); 
title('Input Binary Data'); 
axis([0,N,-0.5,1.5]); 
subplot(4,2,3); 
plotHandle=plot(time,nrzData); 
xlabel('Time'); 
ylabel('Amplitude'); 
title('Polar NRZ encoded data'); 
set(plotHandle,'LineWidth',2.5); 
maxTime=max(time); 
maxAmp=max(nrzData); 
minAmp=min(nrzData); 
axis([0,maxTime,minAmp-1,maxAmp+1]); 
grid on; 
Fc=2*Rb; 
osc1 = cos(2*pi*Fc*time);
osc2= cos(2*pi*Fc*time);
%BPSK modulation 
fskModulated1 = nrzData.*osc1;
fskModulated2 = ~nrzData.*osc2;
subplot(4,2,5);
plot(time,(fskModulated1+fskModulated2)); 
xlabel('Time'); 
ylabel('Amplitude'); 
title('FSK Modulated Data');
% subplot(4,2,7);
% plot(time,fskModulated2); 
% xlabel('Time'); 
% ylabel('Amplitude'); 
% title('FSK Modulated Data2');
maxTime=max(time); 
maxAmp=max(nrzData); 
minAmp=min(nrzData); 
axis([0,maxTime,minAmp-1,maxAmp+1]);
%plotting the PSD of FSK modulated data 
subplot(4,2,7); 
h=spectrum.welch; %Welch spectrum estimator 
Hpsd = psd(h,(fskModulated1+fskModulated2),'Fs',Fs); 
plot(Hpsd); 
title('PSD of FSK modulated Data'); 
%-------------------------------------------
%Adding Channel Noise 
%-------------------------------------------
noise1 = sqrt(noiseVariance)*randn(1,length(fskModulated1));
noise2 = sqrt(noiseVariance)*randn(1,length(fskModulated2));
received1 = fskModulated1 + noise1;
received2 = fskModulated2 + noise2;
subplot(4,2,2); 
plot(time,(received1+received2)); 
xlabel('Time'); 
ylabel('Amplitude'); 
title('FSK Modulated Data with AWGN noise'); 
%FSK Receiver
%-------------------------------------------
%Multiplying the received signal with reference Oscillator 
v1 = received1.*osc1;
v2 = received2.*osc2;
%Integrator 
integrationBase = 0:1/Fs:Tb-1/Fs; 
for i = 0:(length(v1)/(Tb*Fs))-1
y1(i+1)=trapz(integrationBase,v1(int32(i*Tb*Fs+1):int32((i+1)*Tb*Fs))); 
end 
for i = 0:(length(v2)/(Tb*Fs))-1
y2(i+1)=trapz(integrationBase,v2(int32(i*Tb*Fs+1):int32((i+1)*Tb*Fs))); 
end 
y = y1-y2;
%Threshold Comparator 
estimatedBits=(y>=0); 
subplot(4,2,4); 
stem(estimatedBits); 
xlabel('Samples'); 
ylabel('Amplitude'); 
title('Estimated Binary Data'); 
axis([0,N,-0.5,1.5]); 
%------------------------------------------
%Bit Error rate Calculation 
BER = sum(xor(data,estimatedBits))/length(data); 
% %Constellation Mapper at Transmitter side 
% subplot(4,2,6); 
% Q1 = zeros(1,length(nrzData)); %No Quadrature Component for BPSK 
% Q2 = ones(1,length(nrzData));
% scatter(nrzData,Q1);
% hold on;
% %figure(2);
% subplot(4,2,6);
% scatter(nrzData,Q2);
% xlabel('Inphase Component'); 
% ylabel('Quadrature Phase component'); 
% title('QPSK Constellation at Transmitter'); 
% axis([-1.5,1.5,-1,1]); 
% %constellation Mapper at receiver side 
% subplot(4,2,8); 
% Q1 = zeros(1,length(y)); %No Quadrature Component for BPSK
% Q2 = ones(1,length(y));
% stem(y/max(y),Q1);
% hold on;
% %figure(3);
% subplot(4,2,8);
% scatter(y/max(y),Q2);
% %stem(y/max(y),Q); 
% xlabel('Inphase Component'); 
% ylabel('Quadrature Phase component'); 
% title(['QPSK Constellation at Receiver when AWGN Noise Variance =',num2str(noiseVariance)]); 
% axis([-1.5,1.5,-1,1]);

function [time,output,Fs]=NRZ_Encoder(input,Rb,amplitude,style) 

Fs=16*Rb; %Sampling frequency
oversamplingfactor = 32; 
Ts=1/Fs; % Sampling Period 
Tb=1/Rb; % Bit period 
output=[]; 
switch lower(style) 
case {'manchester'} 
for count=1:length(input) 
for tempTime=0:Ts:Tb/2-Ts 
output=[output (-1)^(input(count))*amplitude]; 
end 
for tempTime=Tb/2:Ts:Tb-Ts 
output=[output (-1)^(input(count)+1)*amplitude]; 
end 
end 
case {'unipolar'} 
for count=1:length(input) 
for tempTime=0:Ts:Tb-Ts 
output=[output input(count)*amplitude]; 
end 
end 
case {'polar'} 
for count=1:length(input) 
for tempTime=0:Ts:Tb-Ts 
output=[output amplitude*(-1)^(1+input(count))]; 
end 
end
otherwise 
disp('NRZ_Encoder(input,Rb,amplitude,style)-Unknown method given as ''style'' argument'); 
disp('Accepted Styles are ''Manchester'', ''Unipolar'' and ''Polar'''); 
end 
time=0:Ts:Tb*length(input)-Ts; 
end
           