clear all; close all;
a = arduino('COM3', 'uno')

% set up the graph that will show live motion
h = animatedline;
ax = gca;
ax.YGrid = 'on';
ax.YLim = [-0.1 5];
title('Voltage vs time (live)');
xlabel('Time [HH:MM:SS]');
ylabel('Voltage [volt]');
stop = false;
startTime = datetime('now');

% set up the notes and sound to be played when motion or sound is detected
play_notes ={'E','e','f','g','a','C','D','d'};
freq =[157 169 175 186 230 272 290 333];
play ={'d','e','C','e','C','e','C','C','D','D','E','C','D','E','C','D','C','d','d','e','C','e','C','e','C','a','g','f','a','C','E','D','C','a','D'};
sounds =[.25 .25 .25 .5 .25 .5 .25 1.5 .25 .25 .25 .25 .25 .25 .5 .25 .5 1.5 .25 .25 .25 .5 .25 .5 .25 1.75 .25 .25 .25 .25 .25 .5 .25 .25 .25 1.5 ]; 

while ~stop

% Read current voltage value, A3 is for sound, A1 is for motion sensor
voltage=readVoltage(a,'A3')
voltage2 = readVoltage(a,'A1')
% if voltage from sound and motion sensor is above these values, then turn the light on and play the tone
if voltage>3.2 || voltage2>1.5
  %D4 is for led light, D5 is for buzzer
        writeDigitalPin(a,'D4',1)
        for i = 1:length(play)
            playTone(a,'D5',freq(strcmp(play(i),play_notes)),0.2*sounds(i))
            pause(0.15*sounds(i))
        end
    else 
        writeDigitalPin(a,'D4',0)
        playTone(a,'D5',0,0)
end
% Get current time
t = datetime('now') - startTime;
% Add points to animation,
addpoints(h,datenum(t),voltage)
hold on
addpoints(h,datenum(t),voltage2)
% Update axes
ax.XLim = datenum([t-seconds(15) t]);
datetick('x','keeplimits')
drawnow
% Check stop condition
stop = readDigitalPin(a,'D6');
end
