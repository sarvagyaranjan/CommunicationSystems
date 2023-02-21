 M = 16;
 k = log2(M);
 n = 30000;
 sps = 1;

 rng default
 dataIn = randi([0 1], n, 1);



 stem(dataIn(1:40), 'filled')
 title('Random Bits');
 xlabel('Bit Index');
 ylabel('Binary Value');

 dataSymbolsIn = bit2int(dataIn,k);
figure;                    % Create new figure window.
stem(dataSymbolsIn(1:10));
title('Random Symbols');
xlabel('Symbol Index');
ylabel('Integer Value');
dataMod = qammod(dataSymbolsIn,M,'bin'); % Binary-encoded
dataModG = qammod(dataSymbolsIn,M);      % Gray-encoded
EbNo = 10;
snr = EbNo+10*log10(k)-10*log10(sps);
receivedSignal = awgn(dataMod,snr,'measured');
receivedSignalG = awgn(dataModG,snr,'measured');
sPlotFig = scatterplot(receivedSignal,1,0,'g.');
hold on
scatterplot(dataMod,1,0,'k*',sPlotFig)
dataSymbolsOut = qamdemod(receivedSignal,M,'bin'); % Binary-encoded data symbols
dataSymbolsOutG = qamdemod(receivedSignalG,M);     % Gray-coded data symbols
dataOut = int2bit(dataSymbolsOut,k);
dataOutG = int2bit(dataSymbolsOutG,k);
[numErrors,ber] = biterr(dataIn,dataOut);
fprintf('\nThe binary coding bit error rate is %5.2e, based on %d errors.\n', ...
    ber,numErrors)
[numErrorsG,berG] = biterr(dataIn,dataOutG);
fprintf('\nThe Gray coding bit error rate is %5.2e, based on %d errors.\n', ...
    berG,numErrorsG)


x = (0:15);                   % Integer input
symbin = qammod(x,M,'bin');   % 16-QAM output (binary-coded)
symgray = qammod(x,M,'gray'); % 16-QAM output (Gray-coded)
scatterplot(symgray,1,0,'b*');
for k = 1:M
    text(real(symgray(k)) - 0.0,imag(symgray(k)) + 0.3, ...
        dec2base(x(k),2,4));
     text(real(symgray(k)) - 0.5,imag(symgray(k)) + 0.3, ...
         num2str(x(k)));
    
    text(real(symbin(k)) - 0.0,imag(symbin(k)) - 0.3, ...
        dec2base(x(k),2,4),'Color',[1 0 0]);
    text(real(symbin(k)) - 0.5,imag(symbin(k)) - 0.3, ...
        num2str(x(k)),'Color',[1 0 0]);
end
title('16-QAM Symbol Mapping')
axis([-4 4 -4 4])
