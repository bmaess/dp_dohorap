% load reference table
clear
code = [23, 9, 47, 67, 37, 30, 34, 39, 59, 52, 74, 32, 72, 63, 68, 53, 62, 53, 56, 6, 64, 66, 54, 4, 42, 34, 35, 46, 62, 29, 49, 31, 18, 36, 74, 67, 2, 26, 26, 31, 14, 51, 56, 64, 11, 18, 38, 13, 7, 57, 75, 14, 76, 75, 55, 21, 70, 45, 24, 42, 40, 17, 27, 44, 73, 7, 38, 46, 55, 66, 36, 1, 61, 28, 22, 30, 13, 61, 8, 40, 37, 33, 71, 41, 33, 65, 39, 16, 2, 6, 49, 24, 51, 10, 9, 12, 65, 1, 20, 12, 48, 57, 15, 71, 68, 32, 41, 43, 27, 70, 19, 76, 63, 25, 52, 35, 11, 50, 22, 20, 48, 45, 58, 21, 60, 15, 60, 19, 10, 69, 54, 17, 44, 3, 58, 23, 59, 8, 43, 73, 5, 25, 28, 69, 4, 50, 16, 47, 5, 3, 72, 29, 68, 60, 18, 33, 15, 31, 17, 43, 56, 66, 52, 47, 29, 27, 59, 25, 44, 72, 51, 53, 11, 48, 12, 64, 76, 44, 9, 62, 10, 55, 8, 19, 57, 67, 7, 15, 75, 52, 73, 3, 27, 10, 25, 16, 64, 40, 28, 40, 51, 43, 8, 36, 49, 26, 63, 21, 32, 65, 68, 3, 20, 70, 65, 2, 5, 41, 13, 6, 42, 42, 53, 35, 47, 58, 33, 45, 72, 59, 55, 9, 6, 12, 36, 29, 46, 58, 4, 69, 16, 20, 17, 74, 31, 38, 34, 4, 61, 73, 67, 49, 50, 76, 39, 75, 18, 66, 23, 19, 71, 26, 22, 45, 57, 34, 56, 14, 70, 28, 69, 62, 32, 7, 37, 23, 13, 11, 46, 39, 74, 14, 1, 50, 30, 24, 22, 48, 54, 2, 37, 71, 61, 24, 21, 5, 41, 1, 38, 54, 35, 30, 63, 60];
sName = {'Löwe malt Bär reverse', 'Löwe malt Affe reverse', 'Hase schiebt Igel reverse', 'Löwe kämmt Wolf reverse', 'Wolf malt Fuchs reverse', 'Vogel wäscht Frosch reverse', 'Wolf kämmt Fuchs reverse', 'Fuchs wäscht Hase reverse', 'Hase wäscht Hund reverse', 'Igel kämmt Hund reverse', 'Wolf kämmt Tiger reverse', 'Fuchs kämmt Hase reverse', 'Löwe wäscht Wolf reverse', 'Vogel malt Igel reverse', 'Löwe malt Tiger reverse', 'Hund kämmt Löwe reverse', 'Hund wäscht Tiger reverse', 'Löwe kämmt Hund reverse', 'Hund malt Igel reverse', 'Tiger kämmt Affe reverse', 'Igel wäscht Vogel reverse', 'Löwe kämmt Tiger reverse', 'Hund kämmt Tiger reverse', 'Affe kämmt Hund reverse', 'Fuchs zieht Hund reverse', 'Fuchs kämmt Wolf reverse', 'Hase malt Fuchs reverse', 'Vogel malt Hase reverse', 'Tiger wäscht Hund reverse', 'Käfer wäscht Frosch reverse', 'Hase wäscht Vogel reverse', 'Fuchs fängt Hund reverse', 'Affe zieht Fuchs reverse', 'Fuchs malt Igel reverse', 'Tiger kämmt Wolf reverse', 'Wolf kämmt Löwe reverse', 'Hund fängt Affe reverse', 'Tiger wäscht Bär reverse', 'Bär wäscht Tiger reverse', 'Hund fängt Fuchs reverse', 'Wolf schiebt Affe reverse', 'Hund kämmt Hase reverse', 'Igel malt Hund reverse', 'Vogel wäscht Igel reverse', 'Wolf malt Affe reverse', 'Fuchs zieht Affe reverse', 'Hund schiebt Fuchs reverse', 'Hund schiebt Affe reverse', 'Wolf kämmt Affe reverse', 'Hund malt Löwe reverse', 'Wolf malt Tiger reverse', 'Affe schiebt Wolf reverse', 'Wolf wäscht Tiger reverse', 'Tiger malt Wolf reverse', 'Hase malt Hund reverse', 'Bär kämmt Löwe reverse', 'Löwe schiebt Tiger reverse', 'Hase malt Igel reverse', 'Tiger malt Bär reverse', 'Hund zieht Fuchs reverse', 'Igel wäscht Fuchs reverse', 'Tiger wäscht Affe reverse', 'Frosch malt Käfer reverse', 'Hase kämmt Igel reverse', 'Löwe zieht Tiger reverse', 'Affe kämmt Wolf reverse', 'Fuchs schiebt Hund reverse', 'Hase malt Vogel reverse', 'Hund malt Hase reverse', 'Tiger kämmt Löwe reverse', 'Igel malt Fuchs reverse', 'Fuchs fängt Affe reverse', 'Löwe wäscht Hund reverse', 'Vogel malt Frosch reverse', 'Bär kämmt Tiger reverse', 'Frosch wäscht Vogel reverse', 'Affe schiebt Hund reverse', 'Hund wäscht Löwe reverse', 'Hund malt Affe reverse', 'Fuchs wäscht Igel reverse', 'Fuchs malt Wolf reverse', 'Igel kämmt Fuchs reverse', 'Löwe wäscht Tiger reverse', 'Wolf wäscht Fuchs reverse', 'Fuchs kämmt Igel reverse', 'Löwe fängt Tiger reverse', 'Hase wäscht Fuchs reverse', 'Affe wäscht Löwe reverse', 'Affe fängt Hund reverse', 'Affe kämmt Tiger reverse', 'Vogel wäscht Hase reverse', 'Bär malt Tiger reverse', 'Hase kämmt Hund reverse', 'Tiger malt Affe reverse', 'Affe malt Löwe reverse', 'Affe schiebt Fuchs reverse', 'Tiger fängt Löwe reverse', 'Affe fängt Fuchs reverse', 'Affe zieht Wolf reverse', 'Fuchs schiebt Affe reverse', 'Igel wäscht Hase reverse', 'Löwe malt Hund reverse', 'Hund wäscht Affe reverse', 'Tiger wäscht Löwe reverse', 'Tiger malt Löwe reverse', 'Hase kämmt Fuchs reverse', 'Fuchs wäscht Wolf reverse', 'Hase fängt Igel reverse', 'Käfer malt Frosch reverse', 'Tiger schiebt Löwe reverse', 'Affe zieht Hund reverse', 'Tiger wäscht Wolf reverse', 'Igel malt Vogel reverse', 'Löwe wäscht Bär reverse', 'Hund kämmt Igel reverse', 'Fuchs malt Hase reverse', 'Affe malt Wolf reverse', 'Igel zieht Hase reverse', 'Tiger kämmt Bär reverse', 'Wolf zieht Affe reverse', 'Hase wäscht Igel reverse', 'Igel malt Hase reverse', 'Tiger malt Hund reverse', 'Löwe kämmt Bär reverse', 'Igel wäscht Hund reverse', 'Affe wäscht Hund reverse', 'Hund wäscht Igel reverse', 'Hund zieht Affe reverse', 'Affe malt Tiger reverse', 'Löwe malt Wolf reverse', 'Tiger kämmt Hund reverse', 'Affe wäscht Tiger reverse', 'Igel kämmt Hase reverse', 'Wolf fängt Affe reverse', 'Hund malt Tiger reverse', 'Bär malt Löwe reverse', 'Hund wäscht Hase reverse', 'Affe malt Hund reverse', 'Igel fängt Hase reverse', 'Tiger zieht Löwe reverse', 'Affe kämmt Löwe reverse', 'Bär wäscht Löwe reverse', 'Frosch malt Vogel reverse', 'Wolf malt Löwe reverse', 'Hund kämmt Affe reverse', 'Hase zieht Igel reverse', 'Löwe wäscht Affe reverse', 'Igel schiebt Hase reverse', 'Löwe kämmt Affe reverse', 'Affe fängt Wolf reverse', 'Wolf wäscht Löwe reverse', 'Frosch wäscht Käfer reverse', 'Löwe malt Tiger normal', 'Igel wäscht Hund normal', 'Affe zieht Fuchs normal', 'Fuchs kämmt Igel normal', 'Hund wäscht Affen normal', 'Hund fängt Fuchs normal', 'Affe wäscht Tiger normal', 'Igel fängt Hasen normal', 'Hund malt Igel normal', 'Löwe kämmt Tiger normal', 'Hund kämmt Igel normal', 'Igel schiebt Hasen normal', 'Frosch wäscht Käfer normal', 'Frosch malt Käfer normal', 'Hase wäscht Hund normal', 'Löwe wäscht Bären normal', 'Hase kämmt Igel normal', 'Wolf wäscht Löwen normal', 'Hase kämmt Hund normal', 'Hund kämmt Löwen normal', 'Affe malt Wolf normal', 'Hase wäscht Igel normal', 'Fuchs schiebt Affen normal', 'Igel wäscht Vogel normal', 'Wolf wäscht Tiger normal', 'Igel kämmt Hasen normal', 'Affe malt Löwen normal', 'Hund wäscht Tiger normal', 'Tiger malt Affen normal', 'Hund malt Hasen normal', 'Hund malt Affen normal', 'Affe zieht Hund normal', 'Löwe malt Hund normal', 'Wolf kämmt Löwen normal', 'Wolf kämmt Affen normal', 'Affe wäscht Hund normal', 'Wolf malt Tiger normal', 'Igel kämmt Hund normal', 'Tiger zieht Löwen normal', 'Affe fängt Wolf normal', 'Käfer malt Frosch normal', 'Affe malt Tiger normal', 'Bär wäscht Löwen normal', 'Löwe wäscht Affen normal', 'Vogel wäscht Igel normal', 'Fuchs wäscht Igel normal', 'Frosch malt Vogel normal', 'Igel wäscht Fuchs normal', 'Hund kämmt Hasen normal', 'Hase fängt Igel normal', 'Affe malt Hund normal', 'Igel malt Fuchs normal', 'Hase wäscht Vogel normal', 'Bär wäscht Tiger normal', 'Vogel malt Igel normal', 'Löwe kämmt Bären normal', 'Fuchs kämmt Hasen normal', 'Tiger fängt Löwen normal', 'Tiger malt Löwen normal', 'Wolf fängt Affen normal', 'Affe zieht Wolf normal', 'Tiger schiebt Löwen normal', 'Löwe fängt Tiger normal', 'Hund fängt Affen normal', 'Löwe kämmt Affen normal', 'Fuchs wäscht Wolf normal', 'Affe schiebt Hund normal', 'Tiger kämmt Affen normal', 'Fuchs zieht Hund normal', 'Hund zieht Fuchs normal', 'Löwe kämmt Hund normal', 'Hase malt Fuchs normal', 'Hase schiebt Igel normal', 'Tiger malt Hund normal', 'Igel kämmt Fuchs normal', 'Igel malt Hasen normal', 'Löwe wäscht Wolf normal', 'Hund wäscht Hasen normal', 'Hase malt Hund normal', 'Löwe malt Affen normal', 'Affe kämmt Tiger normal', 'Affe schiebt Fuchs normal', 'Fuchs malt Igel normal', 'Käfer wäscht Frosch normal', 'Hase malt Vogel normal', 'Hund malt Tiger normal', 'Affe kämmt Hund normal', 'Wolf malt Löwen normal', 'Affe wäscht Löwen normal', 'Wolf zieht Affen normal', 'Tiger wäscht Affen normal', 'Tiger kämmt Wolf normal', 'Fuchs fängt Hund normal', 'Hund schiebt Fuchs normal', 'Fuchs kämmt Wolf normal', 'Hund kämmt Affen normal', 'Hund wäscht Löwen normal', 'Löwe zieht Tiger normal', 'Löwe kämmt Wolf normal', 'Vogel wäscht Hasen normal', 'Hase zieht Igel normal', 'Tiger wäscht Wolf normal', 'Fuchs wäscht Hasen normal', 'Tiger malt Wolf normal', 'Fuchs zieht Affen normal', 'Tiger kämmt Löwen normal', 'Bär malt Löwen normal', 'Hund zieht Affen normal', 'Tiger wäscht Löwen normal', 'Tiger wäscht Bären normal', 'Bär kämmt Tiger normal', 'Hase malt Igel normal', 'Hund malt Löwen normal', 'Wolf kämmt Fuchs normal', 'Igel malt Hund normal', 'Affe schiebt Wolf normal', 'Löwe schiebt Tiger normal', 'Vogel malt Frosch normal', 'Löwe malt Wolf normal', 'Tiger wäscht Hund normal', 'Hase kämmt Fuchs normal', 'Affe kämmt Wolf normal', 'Fuchs malt Wolf normal', 'Löwe malt Bären normal', 'Hund schiebt Affen normal', 'Wolf malt Affen normal', 'Vogel malt Hasen normal', 'Hase wäscht Fuchs normal', 'Wolf kämmt Tiger normal', 'Wolf schiebt Affen normal', 'Fuchs fängt Affen normal', 'Igel zieht Hasen normal', 'Frosch wäscht Vogel normal', 'Bär malt Tiger normal', 'Tiger kämmt Bären normal', 'Igel wäscht Hasen normal', 'Hund kämmt Tiger normal', 'Affe fängt Hund normal', 'Wolf malt Fuchs normal', 'Löwe wäscht Tiger normal', 'Löwe wäscht Hund normal', 'Tiger malt Bären normal', 'Bär kämmt Löwen normal', 'Affe kämmt Löwen normal', 'Wolf wäscht Fuchs normal', 'Affe fängt Fuchs normal', 'Fuchs schiebt Hund normal', 'Tiger kämmt Hund normal', 'Fuchs malt Hasen normal', 'Vogel wäscht Frosch normal', 'Igel malt Vogel normal', 'Hund wäscht Igel normal'};
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