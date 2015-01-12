close all;
clearvars;
clc;

ofdmType = 'DCOOFDM';
N = 16; % # subcarriers
M = 4; % M-QAM for each subcarrier

switch lower(ofdmType)
    case 'acoofdm'
        d = N/4;    % number of data carriers per ACOOFDM symbol
    case {'dcoofdm','dmt'}
        d = N/2 - 1;    % number of data carriers per DCOOFDM symbol
    otherwise
        error('OFDM type must be ''ACOOFDM'' or ''DCOOFDM'' or ''DMT''');
end
data = randi(M,[d 1]);

getQAMsyms(M); % show the constellation
Syms = getQAMsyms(M); % get the constellation

% A fixed offset value can be added by using 'Offset' argument. In addition to it :-
% For DCO use 'OffsetDcoStddev' to generate offset per frame by scaling std-dev of each DCO frame
% For ACO use 'OffsetAcoStddev' to generate offset per frame by scaling std-dev of each ACO frame.

% Generate ofdm signal
[tSigDco,tSigM,fSigM] = genOFDMsignal(... % Variable Arguments to the function
    'data',data,...          
    'OFDMtype',ofdmType,...    
    'N',N,...
    'Symbols',Syms,...
    'Offset',0,...
    'OffsetDcoStddev', 3.2);     

% Decode ofdm signal
[tDatV] = decodeOFDMsignal(tSigDco,...
    'OFDMtype',ofdmType,...    
    'N',N,...
    'Symbols',Syms,...
    'Scale',1);

% Plot OFDM signal
figure;
stem(1:numel(tSigDco),tSigDco);
title([ofdmType ' signal']);
xlabel('sample');
ylabel('signal intensity');

% Show transmitted and received data points
figure;
stem(1:d,data,'--bo');
hold on;
stem(1:d,tDatV,'-.rx');
axis([1 d 1 M]);
xlabel('data index');
ylabel('data value (base 10)');
legend('data generated','data decoded');

