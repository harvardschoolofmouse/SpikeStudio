% Written by: Kevin Sayed 6/5/2021
%
clearvars;
loadPath = "/Users/lilis/Dropbox (MIT)/1 ASSAD LAB/testFiles/Ephys Test/00_burgers_VLS_13"; %change this to the folder where your .rhd files are at
savePath = "/Users/lilis/Dropbox (MIT)/1 ASSAD LAB/testFiles/Ephys Test/00_burgers_kilosortsave"; %change this to the folder where your will run kilosort from
figuresPath ="/Users/lilis/Dropbox (MIT)/1 ASSAD LAB/testFiles/Ephys Test/00_burgers_kilosortsave";%change this to the folder where you want the figures to be saved
totalFiles = 12; %set this to how many rhd files you have.
n = 0; %counts how any sample are being saved to the file. 

data = [];
%binary file output location
fid_write = fopen(savePath+'data.dat', 'w');
for k = 1:totalFiles
    clearvars -except amplifier_data fid_write k path n totalFiles savePath figuresPath loadPath;
    read_Intan_RHD2000_file(k+".rhd",loadPath);
    
    amplifier_data2 = remap(amplifier_data);
    
    offset = 1000;
    FS = 30000;
    channelGroups = 8;
    %plot data before cleaning
    if k == 1
        for z =1:128/channelGroups
            figure
            for i=1:channelGroups
                subplot(1,3,1)
                plot((amplifier_data2(i+((z-1)*8),end-(FS*120):end))+(offset*(i-1)))
                hold on
            end
        end
        
    elseif totalFiles>3 && k == round(totalFiles/2)
        for z =1:128/channelGroups
            figure(z)
            for i=1:channelGroups
                subplot(1,3,2)
                plot((amplifier_data2(i+((z-1)*8),end-(FS*120):end))+(offset*(i-1)))
                hold on
            end
        end
        
    elseif k == totalFiles-1
        for z =1:128/channelGroups
            figure(z)
            for i=1:channelGroups
                subplot(1,3,3)
                plot((amplifier_data2(i+((z-1)*8),1:FS*120))+(offset*(i-1)))
                hold on
            end
            %saveas(figure(z),figuresPath+'pre_Figure'+z+'.png');
            %hgsave(z, figuresPath+ z+'pre.fig', '-v7.3');
            %close(z);
        end
    end
    %end of plotting
    
    %clean the data
    n = n+size(amplifier_data2,2);
    clearvars -except amplifier_data2 fid_write k path n totalFiles savePath figuresPath loadPath;
    basicAmplitudeCleaner;
    clearvars -except amplifier_data2 fid_write k path n totalFiles savePath figuresPath loadPath;
    offset = 1000;
    FS = 30000;
    channelGroups = 8;
    
    %plot the data after cleaning;
%     if k == 1
%         for z =1:128/channelGroups
%             figure
%             for i=1:channelGroups
%                 subplot(1,3,1)
%                 plot((amplifier_data2(i+((z-1)*8),end-(FS*120):end))+(offset*(i-1)))
%                 hold on
%             end
%         end
%         
%     elseif totalFiles>3 && k == round(totalFiles/2)
%         for z =1:128/channelGroups
%             for i=1:channelGroups
%                 figure(16+z)
%                 subplot(1,3,2)
%                 plot((amplifier_data2(i+((z-1)*8),end-(FS*120):end))+(offset*(i-1)))
%                 hold on
%             end
%         end
%         
%     elseif k == totalFiles-1
%         for z =1:128/channelGroups
%             for i=1:channelGroups
%                 figure(16+z)
%                 subplot(1,3,3)
%                 plot((amplifier_data2(i+((z-1)*8),1:FS*120))+(offset*(i-1)))
%                 hold on
%             end
%             %saveas(figure(16+z),figuresPath+'post_Figure'+ (16+z)+'.png');
%             %hgsave(16+z, figuresPath+ (16+z)+'post.fig', '-v7.3');
%             %close(16+z);
%         end
%     end
    %end of plotting
    %append data to binary file
    fwrite(fid_write, amplifier_data2, 'int16');
end
%save savePath n;
fclose(fid_write);

function amplifier_data2=remap(amplifier_data)
headstagewiring=[
    1	32
    2	31
    3	30
    4	29
    5	28
    6	27
    7	26
    8	25
    9	24
    10	23
    11	22
    12	21
    13	20
    14	19
    15	18
    16	17
    17	16
    18	15
    19	14
    20	13
    21	12
    22	11
    23	10
    24	9
    25	8
    26	7
    27	6
    28	5
    29	4
    30	3
    31	2
    32	1
    33	64
    34	63
    35	62
    36	61
    37	60
    38	59
    39	58
    40	57
    41	56
    42	55
    43	54
    44	53
    45	52
    46	51
    47	50
    48	49
    49	48
    50	47
    51	46
    52	45
    53	44
    54	43
    55	42
    56	41
    57	40
    58	39
    59	38
    60	37
    61	36
    62	35
    63	34
    64	33
    65	96
    66	95
    67	94
    68	93
    69	92
    70	91
    71	90
    72	89
    73	88
    74	87
    75	86
    76	85
    77	84
    78	83
    79	82
    80	81
    81	80
    82	79
    83	78
    84	77
    85	76
    86	75
    87	74
    88	73
    89	72
    90	71
    91	70
    92	69
    93	68
    94	67
    95	66
    96	65
    97	128
    98	127
    99	126
    100	125
    101	124
    102	123
    103	122
    104	121
    105	120
    106	119
    107	118
    108	117
    109	116
    110	115
    111	114
    112	113
    113	112
    114	111
    115	110
    116	109
    117	108
    118	107
    119	106
    120	105
    121	104
    122	103
    123	102
    124	101
    125	100
    126	99
    127	98
    128	97
    ];

mapping = sortrows(headstagewiring,2);
amplifier_data2 = amplifier_data(mapping(:,1),:);
end