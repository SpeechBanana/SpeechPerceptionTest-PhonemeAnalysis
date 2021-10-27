% patched BEST! Advanced cost functions
function [bestalign,numberofalignments] = AlignPhonemes(X,Y,consdict,vowdict,mannerdict,mult)
% keyboard
%X = {'a','b','j', 'd','e','f'};
%Y = {'b', 'a'};
%X = {'b', 'c', 'a', 'd', 'b', 'a'};
lenX = length(X);
lenY = length(Y);

if strcmp(Y, '')
    disp('ERROR: unable to align with empty guess')
    bestalign = cell(2, lenX);
    for i = 1 : lenX
        bestalign{2,i} = X{i};
        bestalign{1,i} = 'qq';
    end
    bestalign
    return
end

% low costs for adding at beginning and end
low = 1;

% we will compute distance matrix of the initial subsequences
D = nan(lenX+1,lenY+1);
% also for backtrace will be 1 for del, 2 for ins, 3 for sub
% substitution
P = cell(lenX,lenY);

% begin
D(1,1) = 0;
P{1,1} = {[0,0]};
%if X is empty, return and empty guess
if lenX==1 && isempty(X{1})
    for i = 1:lenY
        bestalign{1,i} = ' ';
        bestalign{2,i} = Y{i};
    end
    return
end
% match x to an empty y by deleting x
for i = 1 : lenX
    D(i+1,1) = 1 + D(i,1);
    P{i+1,1} = {[1,1]};
end 
% match empty x to y by adding
for j = 1 : lenY
    D(1,j+1) = 1 + D(1,j);
    P{1,j+1} = {[2,1]};
end

% now we populate the matrix
for i = 1 : lenX
    for j = 1 : lenY
        % we evaluate three things
        [costdel, delInd]   = del_cost(P{i,j+1}); %cost if you deleted  X{i}
        [costins, insInd]   = ins_cost(P{i+1,j}); %cost if you inserted Y{j}
        [costsub, subInd] = sub_cost(X{i},Y{j},P{i,j}, vowdict, consdict, mannerdict);
        allInds = [delInd,insInd,subInd];
        Ddel = D(i+1-1,j+1) + costdel*(1-(i==lenX)*(1-low));
        Dins = D(i+1,j+1-1) + costins*(1-(i==lenX)*(1-low));
        Dsub = D(i+1-1,j+1-1) + costsub;
        
        arr = [Ddel,Dins,Dsub];
        minD = min([Ddel,Dins,Dsub]);
        hold = {};
        for k = 1 : 3
            if arr(k) == minD
                hold{end+1} = [k,allInds(k)];
            end
        end
        D(i+1,j+1) = minD;
        P{i+1,j+1} = hold;
    end
end

% now we compute the alignment
seqs = find_seqs(P, lenX, lenY);

allalignments = cell(1, length(seqs));
for k = 1 : length(seqs)
        allalignments{k} = follow(seqs{k}, X, Y);
end

numberofalignments = length(allalignments);
if length(allalignments) > 1
    fprintf('Multiple alignments were found, specifically %d\n', length(allalignments));
    for k = 1: length(allalignments)
         fprintf('Option %d\n', k)
         disp(flipud(allalignments{k}))
         fprintf('\n')
    end
    if (mult == true)
        bestchoice = input('Choose which option you want (only enter a number)\n');
        bestalign = allalignments{bestchoice};
    else
        bestalign = allalignments{1};
    end
else
    bestalign = allalignments{1};
end
end

% below are simple costs for the current operation which is insertion
function [cost, ind] = ins_cost(Parr)
%%%Table 2 (left) in Ratnanather et al. (2022)
%%%previous op: Parr{i}(1)==2 is insertion
for i = 1 : length(Parr)
	if Parr{i}(1) == 2
		cost = 1;
		ind = i;
		return
	end
end
%%%else previous op is sub/del 
cost = 1.5;
ind = 1;
end

% below are simple costs for the current operation which is deletion
function [cost, ind] = del_cost(Parr)
%%%Table 2 (left) in Ratnanather et al. (2022)
%%%previous op: Parr{i}(1)==1 is deletion
for i = 1 : length(Parr)
	if Parr{i}(1) == 1
		cost = 1;
		ind = i;
		return
	end
end
%%%else previous op is ins/sub
cost = 1.5;
ind = 1;
end

% a better one, consonants and vowels and smilarity deductions
%Table 2 (right) in Ratnanather et al. (2022)
function [cost, ind] = sub_cost(symbol1,symbol2,Parr, vowdict, consdict, mannerdict)
one_is_vowel = sum(symbol1(1)=='AEIOU');
two_is_vowel = sum(symbol2(1)=='AEIOU');
best = 10;
ind = 1;
for i = 1 : length(Parr)
	%initialize currcost according to whether the last op was 
    %a deletion which has an additive cost of 0.5
    %a insertion which has an additive cost of 0.1
    %a match which has zero cost
	if Parr{i}(1) == 1 %%% deletion
		currcost = 0.5;
    elseif Parr{i}(1) == 2 %%% insertion
        currcost = 0.1;
    else %%%match
		currcost = 0;
	end
 
%%% Current operation is substitution
%%% If previous operation was insertion or deletion
	if xor(one_is_vowel, two_is_vowel)
%%% vowel-consonant or vice-versa
		currcost = currcost + 5;
	elseif ~one_is_vowel
%%% consonant-consonant
		currcost = currcost + 1.75;
		if isKey(consdict, symbol1) && sum(strcmp(symbol2, consdict(symbol1)))
%           fidc = fopen('ConsPairs.txt','a');
%           fprintf(fidc,'%s %s\n',symbol1,symbol2);
%           fclose(fidc);
%%%         decrement for similar consonant i.e. 1.2 = 1.75 - 0.55
			currcost = currcost - .55;
		elseif isKey(mannerdict, symbol1) && sum(strcmp(symbol2, mannerdict(symbol1)))
%           fidm = fopen('MannerPairs.txt','a');
%           fprintf(fidm,'%s %s\n',symbol1,symbol2);
%           fclose(fidm);
%%%         decrement for same manner consonant i.e. 1.3 = 1.75 - 0.45
			currcost = currcost - .45;
		elseif strcmp(symbol1,symbol2)
%%%         matched consonants: suppose the initialised currcost is 0.5 (Parr{i}(1)==1, deletion) then must
%%%         decrement by 1.75 and a further 0.3 to bring down to 
%%%         0.2 if previous op was deletion or 0.1 if previous op was insertion
%%%         otherwise  if it was 0.1 (Parr{i}(1) == 2, insertion) then the result is a negative number because it is a matched 
			currcost = currcost - 1.75 - 0.3;
			if currcost < 0
				cost = 0;
				ind = i;
				return
			end
		end
	elseif one_is_vowel
%%%     vowel-vowel
		currcost = currcost + 0.9;
		if isKey(vowdict, symbol1) && sum(strcmp(symbol2, vowdict(symbol1)))
%           fidv= fopen('VowPairs.txt','a');
%           fprintf(fidv,'%s %s\n',symbol1,symbol2);
%           fclose(fidv);
%%%         decrement for similar vowel i.e. 0.65 = 0.9 - 0.25
			currcost = currcost - .25;
		elseif strcmp(symbol1,symbol2)
%%%         matched vowels: suppose the initialised currcost is 0.5 (Parr{i}(1)==1, deletion) then must
%%%         decrement by 0.9 and a further 0.3 to bring down to 
%%%         0.2 if previous op was deletion or 0.1 if previous op was insertion
%%%         otherwise  if it was 0.1 (Parr{i}(1) == 2, insertion) then the result is a negative number because it is a matched 
			currcost = currcost - 0.9 - 0.3;
			if currcost < 0
				cost = 0;
				ind = i;
				return
			end
		end
	end
	if currcost < best
		best = currcost;
		ind = i;
	end
end
cost = best;
end

function seqs = find_seqs(P, lenX, lenY)
global all_seqs;
all_seqs = {};
%take first steps
i = lenX+1;
j = lenY+1;
first = P{i,j};
for k = 1 : length(first)
    choice = k;
    take_step(P, i, j, choice, []);
    
end
seqs = all_seqs;
end

function take_step(P, i, j, choice, currseq)
global all_seqs;
if i == 1 && j == 1
    all_seqs = [all_seqs, currseq];
else
    to_check = P{i,j}{choice};
    step = to_check(1);
    currseq = [step, currseq];
    if step == 3 % sub
        newi = i-1;
        newj = j-1;
    elseif step == 2 %ins
        newi = i;
        newj = j-1;
    elseif step == 1 %del
        newi = i-1;
        newj = j;
    end
    nextchoice = to_check(2);
    take_step(P, newi, newj, nextchoice, currseq);
end
    
end


function aligned = follow(seq,X,Y)
% now follow the instructions
aligned = cell(2,length(seq));
xcount = 1;
ycount = 1;
for i = 1 : length(seq)
    if seq(i) == 3 %if you're supposed to substitute
        aligned{2,i} = X{xcount};
        aligned{1,i} = Y{ycount};
        xcount = xcount + 1;
        ycount = ycount + 1;
    elseif seq(i) == 2 %if you're supposed to insert
        aligned{2,i} = ' ';
        aligned{1,i} = Y{ycount};
        ycount = ycount + 1;
    elseif seq(i) == 1 %if you're supposed to delete
        aligned{2,i} = X{xcount};
        aligned{1,i} = ' ';
        xcount = xcount + 1;
    end
end
end
