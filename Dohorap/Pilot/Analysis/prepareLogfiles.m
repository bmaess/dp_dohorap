% load reference table
clear
code = [23, 9, 47, 67, 37, 30, 34, 39, 59, 52, 74, 32, 72, 63, 68, 53, 62, 53, 56, 6, 64, 66, 54, 4, 42, 34, 35, 46, 62, 29, 49, 31, 18, 36, 74, 67, 2, 26, 26, 31, 14, 51, 56, 64, 11, 18, 38, 13, 7, 57, 75, 14, 76, 75, 55, 21, 70, 45, 24, 42, 40, 17, 27, 44, 73, 7, 38, 46, 55, 66, 36, 1, 61, 28, 22, 30, 13, 61, 8, 40, 37, 33, 71, 41, 33, 65, 39, 16, 2, 6, 49, 24, 51, 10, 9, 12, 65, 1, 20, 12, 48, 57, 15, 71, 68, 32, 41, 43, 27, 70, 19, 76, 63, 25, 52, 35, 11, 50, 22, 20, 48, 45, 58, 21, 60, 15, 60, 19, 10, 69, 54, 17, 44, 3, 58, 23, 59, 8, 43, 73, 5, 25, 28, 69, 4, 50, 16, 47, 5, 3, 72, 29, 68, 60, 18, 33, 15, 31, 17, 43, 56, 66, 52, 47, 29, 27, 59, 25, 44, 72, 51, 53, 11, 48, 12, 64, 76, 44, 9, 62, 10, 55, 8, 19, 57, 67, 7, 15, 75, 52, 73, 3, 27, 10, 25, 16, 64, 40, 28, 40, 51, 43, 8, 36, 49, 26, 63, 21, 32, 65, 68, 3, 20, 70, 65, 2, 5, 41, 13, 6, 42, 42, 53, 35, 47, 58, 33, 45, 72, 59, 55, 9, 6, 12, 36, 29, 46, 58, 4, 69, 16, 20, 17, 74, 31, 38, 34, 4, 61, 73, 67, 49, 50, 76, 39, 75, 18, 66, 23, 19, 71, 26, 22, 45, 57, 34, 56, 14, 70, 28, 69, 62, 32, 7, 37, 23, 13, 11, 46, 39, 74, 14, 1, 50, 30, 24, 22, 48, 54, 2, 37, 71, 61, 24, 21, 5, 41, 1, 38, 54, 35, 30, 63, 60];
sName = {'L�we malt B�r reverse', 'L�we malt Affe reverse', 'Hase schiebt Igel reverse', 'L�we k�mmt Wolf reverse', 'Wolf malt Fuchs reverse', 'Vogel w�scht Frosch reverse', 'Wolf k�mmt Fuchs reverse', 'Fuchs w�scht Hase reverse', 'Hase w�scht Hund reverse', 'Igel k�mmt Hund reverse', 'Wolf k�mmt Tiger reverse', 'Fuchs k�mmt Hase reverse', 'L�we w�scht Wolf reverse', 'Vogel malt Igel reverse', 'L�we malt Tiger reverse', 'Hund k�mmt L�we reverse', 'Hund w�scht Tiger reverse', 'L�we k�mmt Hund reverse', 'Hund malt Igel reverse', 'Tiger k�mmt Affe reverse', 'Igel w�scht Vogel reverse', 'L�we k�mmt Tiger reverse', 'Hund k�mmt Tiger reverse', 'Affe k�mmt Hund reverse', 'Fuchs zieht Hund reverse', 'Fuchs k�mmt Wolf reverse', 'Hase malt Fuchs reverse', 'Vogel malt Hase reverse', 'Tiger w�scht Hund reverse', 'K�fer w�scht Frosch reverse', 'Hase w�scht Vogel reverse', 'Fuchs f�ngt Hund reverse', 'Affe zieht Fuchs reverse', 'Fuchs malt Igel reverse', 'Tiger k�mmt Wolf reverse', 'Wolf k�mmt L�we reverse', 'Hund f�ngt Affe reverse', 'Tiger w�scht B�r reverse', 'B�r w�scht Tiger reverse', 'Hund f�ngt Fuchs reverse', 'Wolf schiebt Affe reverse', 'Hund k�mmt Hase reverse', 'Igel malt Hund reverse', 'Vogel w�scht Igel reverse', 'Wolf malt Affe reverse', 'Fuchs zieht Affe reverse', 'Hund schiebt Fuchs reverse', 'Hund schiebt Affe reverse', 'Wolf k�mmt Affe reverse', 'Hund malt L�we reverse', 'Wolf malt Tiger reverse', 'Affe schiebt Wolf reverse', 'Wolf w�scht Tiger reverse', 'Tiger malt Wolf reverse', 'Hase malt Hund reverse', 'B�r k�mmt L�we reverse', 'L�we schiebt Tiger reverse', 'Hase malt Igel reverse', 'Tiger malt B�r reverse', 'Hund zieht Fuchs reverse', 'Igel w�scht Fuchs reverse', 'Tiger w�scht Affe reverse', 'Frosch malt K�fer reverse', 'Hase k�mmt Igel reverse', 'L�we zieht Tiger reverse', 'Affe k�mmt Wolf reverse', 'Fuchs schiebt Hund reverse', 'Hase malt Vogel reverse', 'Hund malt Hase reverse', 'Tiger k�mmt L�we reverse', 'Igel malt Fuchs reverse', 'Fuchs f�ngt Affe reverse', 'L�we w�scht Hund reverse', 'Vogel malt Frosch reverse', 'B�r k�mmt Tiger reverse', 'Frosch w�scht Vogel reverse', 'Affe schiebt Hund reverse', 'Hund w�scht L�we reverse', 'Hund malt Affe reverse', 'Fuchs w�scht Igel reverse', 'Fuchs malt Wolf reverse', 'Igel k�mmt Fuchs reverse', 'L�we w�scht Tiger reverse', 'Wolf w�scht Fuchs reverse', 'Fuchs k�mmt Igel reverse', 'L�we f�ngt Tiger reverse', 'Hase w�scht Fuchs reverse', 'Affe w�scht L�we reverse', 'Affe f�ngt Hund reverse', 'Affe k�mmt Tiger reverse', 'Vogel w�scht Hase reverse', 'B�r malt Tiger reverse', 'Hase k�mmt Hund reverse', 'Tiger malt Affe reverse', 'Affe malt L�we reverse', 'Affe schiebt Fuchs reverse', 'Tiger f�ngt L�we reverse', 'Affe f�ngt Fuchs reverse', 'Affe zieht Wolf reverse', 'Fuchs schiebt Affe reverse', 'Igel w�scht Hase reverse', 'L�we malt Hund reverse', 'Hund w�scht Affe reverse', 'Tiger w�scht L�we reverse', 'Tiger malt L�we reverse', 'Hase k�mmt Fuchs reverse', 'Fuchs w�scht Wolf reverse', 'Hase f�ngt Igel reverse', 'K�fer malt Frosch reverse', 'Tiger schiebt L�we reverse', 'Affe zieht Hund reverse', 'Tiger w�scht Wolf reverse', 'Igel malt Vogel reverse', 'L�we w�scht B�r reverse', 'Hund k�mmt Igel reverse', 'Fuchs malt Hase reverse', 'Affe malt Wolf reverse', 'Igel zieht Hase reverse', 'Tiger k�mmt B�r reverse', 'Wolf zieht Affe reverse', 'Hase w�scht Igel reverse', 'Igel malt Hase reverse', 'Tiger malt Hund reverse', 'L�we k�mmt B�r reverse', 'Igel w�scht Hund reverse', 'Affe w�scht Hund reverse', 'Hund w�scht Igel reverse', 'Hund zieht Affe reverse', 'Affe malt Tiger reverse', 'L�we malt Wolf reverse', 'Tiger k�mmt Hund reverse', 'Affe w�scht Tiger reverse', 'Igel k�mmt Hase reverse', 'Wolf f�ngt Affe reverse', 'Hund malt Tiger reverse', 'B�r malt L�we reverse', 'Hund w�scht Hase reverse', 'Affe malt Hund reverse', 'Igel f�ngt Hase reverse', 'Tiger zieht L�we reverse', 'Affe k�mmt L�we reverse', 'B�r w�scht L�we reverse', 'Frosch malt Vogel reverse', 'Wolf malt L�we reverse', 'Hund k�mmt Affe reverse', 'Hase zieht Igel reverse', 'L�we w�scht Affe reverse', 'Igel schiebt Hase reverse', 'L�we k�mmt Affe reverse', 'Affe f�ngt Wolf reverse', 'Wolf w�scht L�we reverse', 'Frosch w�scht K�fer reverse', 'L�we malt Tiger normal', 'Igel w�scht Hund normal', 'Affe zieht Fuchs normal', 'Fuchs k�mmt Igel normal', 'Hund w�scht Affen normal', 'Hund f�ngt Fuchs normal', 'Affe w�scht Tiger normal', 'Igel f�ngt Hasen normal', 'Hund malt Igel normal', 'L�we k�mmt Tiger normal', 'Hund k�mmt Igel normal', 'Igel schiebt Hasen normal', 'Frosch w�scht K�fer normal', 'Frosch malt K�fer normal', 'Hase w�scht Hund normal', 'L�we w�scht B�ren normal', 'Hase k�mmt Igel normal', 'Wolf w�scht L�wen normal', 'Hase k�mmt Hund normal', 'Hund k�mmt L�wen normal', 'Affe malt Wolf normal', 'Hase w�scht Igel normal', 'Fuchs schiebt Affen normal', 'Igel w�scht Vogel normal', 'Wolf w�scht Tiger normal', 'Igel k�mmt Hasen normal', 'Affe malt L�wen normal', 'Hund w�scht Tiger normal', 'Tiger malt Affen normal', 'Hund malt Hasen normal', 'Hund malt Affen normal', 'Affe zieht Hund normal', 'L�we malt Hund normal', 'Wolf k�mmt L�wen normal', 'Wolf k�mmt Affen normal', 'Affe w�scht Hund normal', 'Wolf malt Tiger normal', 'Igel k�mmt Hund normal', 'Tiger zieht L�wen normal', 'Affe f�ngt Wolf normal', 'K�fer malt Frosch normal', 'Affe malt Tiger normal', 'B�r w�scht L�wen normal', 'L�we w�scht Affen normal', 'Vogel w�scht Igel normal', 'Fuchs w�scht Igel normal', 'Frosch malt Vogel normal', 'Igel w�scht Fuchs normal', 'Hund k�mmt Hasen normal', 'Hase f�ngt Igel normal', 'Affe malt Hund normal', 'Igel malt Fuchs normal', 'Hase w�scht Vogel normal', 'B�r w�scht Tiger normal', 'Vogel malt Igel normal', 'L�we k�mmt B�ren normal', 'Fuchs k�mmt Hasen normal', 'Tiger f�ngt L�wen normal', 'Tiger malt L�wen normal', 'Wolf f�ngt Affen normal', 'Affe zieht Wolf normal', 'Tiger schiebt L�wen normal', 'L�we f�ngt Tiger normal', 'Hund f�ngt Affen normal', 'L�we k�mmt Affen normal', 'Fuchs w�scht Wolf normal', 'Affe schiebt Hund normal', 'Tiger k�mmt Affen normal', 'Fuchs zieht Hund normal', 'Hund zieht Fuchs normal', 'L�we k�mmt Hund normal', 'Hase malt Fuchs normal', 'Hase schiebt Igel normal', 'Tiger malt Hund normal', 'Igel k�mmt Fuchs normal', 'Igel malt Hasen normal', 'L�we w�scht Wolf normal', 'Hund w�scht Hasen normal', 'Hase malt Hund normal', 'L�we malt Affen normal', 'Affe k�mmt Tiger normal', 'Affe schiebt Fuchs normal', 'Fuchs malt Igel normal', 'K�fer w�scht Frosch normal', 'Hase malt Vogel normal', 'Hund malt Tiger normal', 'Affe k�mmt Hund normal', 'Wolf malt L�wen normal', 'Affe w�scht L�wen normal', 'Wolf zieht Affen normal', 'Tiger w�scht Affen normal', 'Tiger k�mmt Wolf normal', 'Fuchs f�ngt Hund normal', 'Hund schiebt Fuchs normal', 'Fuchs k�mmt Wolf normal', 'Hund k�mmt Affen normal', 'Hund w�scht L�wen normal', 'L�we zieht Tiger normal', 'L�we k�mmt Wolf normal', 'Vogel w�scht Hasen normal', 'Hase zieht Igel normal', 'Tiger w�scht Wolf normal', 'Fuchs w�scht Hasen normal', 'Tiger malt Wolf normal', 'Fuchs zieht Affen normal', 'Tiger k�mmt L�wen normal', 'B�r malt L�wen normal', 'Hund zieht Affen normal', 'Tiger w�scht L�wen normal', 'Tiger w�scht B�ren normal', 'B�r k�mmt Tiger normal', 'Hase malt Igel normal', 'Hund malt L�wen normal', 'Wolf k�mmt Fuchs normal', 'Igel malt Hund normal', 'Affe schiebt Wolf normal', 'L�we schiebt Tiger normal', 'Vogel malt Frosch normal', 'L�we malt Wolf normal', 'Tiger w�scht Hund normal', 'Hase k�mmt Fuchs normal', 'Affe k�mmt Wolf normal', 'Fuchs malt Wolf normal', 'L�we malt B�ren normal', 'Hund schiebt Affen normal', 'Wolf malt Affen normal', 'Vogel malt Hasen normal', 'Hase w�scht Fuchs normal', 'Wolf k�mmt Tiger normal', 'Wolf schiebt Affen normal', 'Fuchs f�ngt Affen normal', 'Igel zieht Hasen normal', 'Frosch w�scht Vogel normal', 'B�r malt Tiger normal', 'Tiger k�mmt B�ren normal', 'Igel w�scht Hasen normal', 'Hund k�mmt Tiger normal', 'Affe f�ngt Hund normal', 'Wolf malt Fuchs normal', 'L�we w�scht Tiger normal', 'L�we w�scht Hund normal', 'Tiger malt B�ren normal', 'B�r k�mmt L�wen normal', 'Affe k�mmt L�wen normal', 'Wolf w�scht Fuchs normal', 'Affe f�ngt Fuchs normal', 'Fuchs schiebt Hund normal', 'Tiger k�mmt Hund normal', 'Fuchs malt Hasen normal', 'Vogel w�scht Frosch normal', 'Igel malt Vogel normal', 'Hund w�scht Igel normal'};
side = [2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 2, 1, 1, 2, 2, 1, 1, 2, 1, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 2, 2, 1, 1, 2, 2, 2, 1, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1, 1, 1, 2, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 1, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 2, 2, 1, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 1, 1, 1, 2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 2, 2, 2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2];
jitter = [600, 706, 619, 439, 597, 550, 599, 401, 517, 546, 672, 448, 687, 477, 597, 708, 565, 542, 799, 407, 722, 431, 800, 482, 725, 745, 444, 630, 794, 730, 586, 410, 759, 534, 431, 589, 779, 643, 784, 543, 789, 583, 761, 507, 544, 793, 454, 530, 670, 620, 501, 515, 581, 643, 744, 556, 661, 510, 533, 420, 662, 535, 455, 450, 455, 719, 454, 684, 411, 624, 517, 643, 767, 623, 615, 429, 738, 747, 723, 496, 508, 617, 465, 401, 782, 469, 489, 730, 762, 792, 516, 400, 410, 522, 501, 667, 717, 728, 452, 439, 686, 579, 453, 512, 794, 794, 755, 646, 614, 423, 769, 681, 495, 764, 514, 747, 554, 647, 567, 551, 722, 486, 472, 412, 437, 434, 483, 571, 747, 556, 721, 732, 500, 777, 513, 678, 566, 440, 400, 485, 488, 733, 737, 526, 528, 738, 612, 637, 764, 751, 675, 792, 742, 411, 520, 665, 629, 695, 734, 673, 547, 732, 500, 769, 405, 517, 660, 640, 535, 596, 687, 788, 570, 767, 426, 733, 556, 514, 515, 719, 577, 567, 739, 468, 425, 720, 479, 776, 591, 632, 531, 768, 738, 517, 674, 494, 663, 780, 576, 583, 777, 721, 632, 600, 778, 685, 668, 450, 536, 683, 580, 646, 534, 730, 784, 407, 429, 515, 765, 755, 795, 572, 493, 776, 709, 769, 657, 536, 665, 747, 538, 736, 611, 722, 580, 778, 521, 708, 499, 744, 565, 495, 449, 457, 498, 539, 732, 583, 541, 642, 456, 693, 613, 633, 653, 500, 571, 410, 685, 551, 646, 704, 718, 410, 794, 438, 639, 787, 459, 602, 627, 538, 495, 425, 421, 571, 524, 583, 761, 672, 625, 775, 494, 408, 449, 526, 601, 795, 691, 442, 591, 408, 625, 587, 787, 502, 685, 756, 492, 431, 785, 460, 406, 513];
responses = cell(1,21);
words = cell(1,1);

for subjectID = 1:21
    % load subject logfile
    logFilename = ['../Data/main_dh' sprintf('%02d', subjectID), '.log'];
    logfile = importPresentationLog(logFilename);

    stimulusActive = 0;
    oldtrial = 0;
    responseTrial = 0;
    responses{subjectID} = [];
    responseList = {};
    wordlist = {};
    for i = 1:2 % iterate over words in sentence
        m = 0;
        wordlist = {};
        for n = 1:numel(sName) % iterate over trials
        sentence = regexp(sName{n},' ','split'); % split sentence
            word = sentence{i}; % extract ith word
            wordFound = 0;
            for o = 1:size(wordlist,2) % search for a match in the current wordlist
                if strcmp(wordlist{o}, word) == 1; wordFound = 1; end;
            end;
            if wordFound == 0
                m = m + 1;
                wordlist{m} = word;
            end;
        end;
        for n = 1:size(wordlist,2)
            words{i,n} = wordlist{n};
        end;
    end;
    clear wordlist m o i n sentence word wordFound
    % Duplicate the first row to the last
    for w = 1:size(words,2)
        words{3,w} = words{1,w};
    end

    for n = 1:size(logfile,2)
        % new trial? reset everything
        if oldtrial ~= logfile(n).trial
            stimulusActive = 0;
            stimulusStartTime = NaN;
            stimulusEndTime = NaN;
            stimulusSpeechCode = NaN;
            stimulusPicCode = NaN;
        end;

        % sound event? set stimulus flag
        if strcmp(logfile(n).event_type, 'Sound')
            stimulusActive = 1;
            stimulusSpeechCode = str2num(logfile(n).code);
            stimulusStartTime = logfile(n).time;
            if stimulusSpeechCode > 304
                stimulusSpeechCode = stimulusSpeechCode - 304;
            end
        end;

        % picture event? save event code
        if strcmp(logfile(n).event_type, 'Picture')
            stimulusPicCode = str2num(logfile(n).code);
        end;

        % sound currently running?
        if stimulusActive == 1

            % search for response (this will automatically use the _last_ response in the current trial)     
            if strcmp(logfile(n).event_type, 'Response')
                responseTrial = responseTrial +1;
                r = -ones(9,1);
                stimulusEndTime = logfile(n).time;
                responseKey = str2num(logfile(n).code);
                expectedKey = side(stimulusSpeechCode);
                sentence = regexp(sName{stimulusSpeechCode},' ','split');
                for wordtype = 1:3
                    fitword = 0;
                    for word = 1:size(words,2)
                        if strcmp(sentence{wordtype}, words{wordtype, word}) == 1
                            fitword = word;
                        end;
                    end;
                    r(wordtype+5,1) = fitword;
                end;

                % save response data
                r(1,1) = stimulusSpeechCode;
                r(2,1) = (stimulusEndTime - stimulusStartTime)/10000;
                r(3,1) = jitter(responseTrial);
                r(4,1) = expectedKey == responseKey;
                if responseKey > 2; r(4,1) = -1; end
                r(5,1) = responseKey;
                r(9,1) = logfile(n).trial;
                responses{subjectID} = [responses{subjectID}, r];

            end;
        end;
        oldtrial = logfile(n).trial;
    end;
    if subjectID == 3
        t = 3;
    end
end
responseList{1} = 'SpeechCode';
responseList{2} = 'ResponseTime';
responseList{3} = 'JitterTime';
responseList{4} = 'ResponseCorrect';
responseList{5} = 'ResponseSide';
responseList{6} = 'SubjectWord';
responseList{7} = 'VerbWord';
responseList{8} = 'ObjectWord';
responseList{9} = 'Trial';

save('responseData.mat', 'responses', 'words', 'responseList');