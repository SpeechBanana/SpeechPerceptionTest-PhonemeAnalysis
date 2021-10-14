% patched BEST! Advanced cost functions
%Sept 2021 - commented out lines for writing files for validation
function [bestalign] = AlignPhonemes(X,Y,consdict,vowdict,mannerdict)
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
        [costdel, delInd] = del_cost(P{i,j+1}); %cost if you deleted X{i}
        [costins, insInd] = ins_cost(P{i+1,j}); %cost if you inserted Y{j}
        [costsub, subInd] = sub_cost(X{i},Y{j},P{i,j}, vowdict, consdict, mannerdict);
        P{i,j};
        allInds = [delInd,insInd,subInd];
        
        Ddel = D(i+1-1,j+1) + costdel*(1-(i==lenX)*(1-low));
        Dins = D(i+1,j+1-1) + costins*(1-(i==lenX)*(1-low));
        Dsub = D(i+1-1,j+1-1) + costsub;
        
        %disp('full')
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
    %D
end
% keyboard

% now we compute the alignment
i = lenX+1;
j = lenY+1;

%currseq is the sequence up to present
currseq = {};
%keep going until you hit the first element
while i > 1 || j > 1
    %as long as you're not already done, add the next move to currseq
    if ~(i == 1 && j == 1)
        currseq = [P{i,j}{1}(1),currseq];
    else
        break
    end
    
    %update i and j based on the operation you just did
    if P{i,j}{1}(1) == 3 %sub
        i = i-1;
        j = j-1;
    elseif P{i,j}{1}(1) == 2 %ins
        %i = i;
        j = j - 1;
    elseif P{i,j}{1}(1) == 1 %del
        i = i - 1;
        %j = j;
    end
end

bestalign = follow(currseq,X,Y);
end


% below are simple costs
function [cost, ind] = ins_cost(Parr)
for i = 1 : length(Parr)
	if Parr{i}(1) == 2
		cost = 1;
		ind = i;
		return
	end
end
cost = 1.5;
ind = 1;
end

function [cost, ind] = del_cost(Parr)
for i = 1 : length(Parr)
	if Parr{i}(1) == 1
		cost = 1;
		ind = i;
		return
	end
end
cost = 1.5;
ind = 1;
end

% a better one, consonants and vowels and smilarity deductions
function [cost, ind] = sub_cost(symbol1,symbol2,Parr, vowdict, consdict, mannerdict)
one_is_vowel = sum(symbol1(1)=='AEIOU');
two_is_vowel = sum(symbol2(1)=='AEIOU');
best = 3;
ind = 1;
for i = 1 : length(Parr)
	%initialize currcost according to whether the last op was a deletion
	if Parr{i}(1) == 1
		currcost = 0.5;
	else
		currcost = 0;
	end
 
	if xor(one_is_vowel, two_is_vowel)
		currcost = currcost + 2;
	elseif ~one_is_vowel
		currcost = currcost + 1.75;
		if isKey(consdict, symbol1) && sum(strcmp(symbol2, consdict(symbol1)))
%%%Added Sept 2021
%                 fidc = fopen('ConsPairs.txt','a');
%                 fprintf(fidc,'%s %s\n',symbol1,symbol2);
%                 fclose(fidc);
			currcost = currcost - .55;
		elseif isKey(mannerdict, symbol1) && sum(strcmp(symbol2, mannerdict(symbol1)))
%%%Added Sept 2021
%                 fidm = fopen('MannerPairs.txt','a');
%                 fprintf(fidm,'%s %s\n',symbol1,symbol2);
%                 fclose(fidm);
			currcost = currcost - .45;
		elseif strcmp(symbol1,symbol2)
			currcost = currcost - 1.75 - 0.3;
			if currcost < 0
				cost = 0;
				ind = i;
				return
			end
		end
	elseif one_is_vowel
		currcost = currcost + 0.9;
		if isKey(vowdict, symbol1) && sum(strcmp(symbol2, vowdict(symbol1)))
%%%Added Sept 2021
%                 fidv= fopen('VowPairs.txt','a');
%                 fprintf(fidv,'%s %s\n',symbol1,symbol2);
%                 fclose(fidv);
			currcost = currcost - .25;
		elseif strcmp(symbol1,symbol2)
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

function aligned = follow(seq,X,Y)
% now follow the instructions
aligned = cell(2,length(seq));
xcount = 1;
ycount = 1;
for i = 1 : length(seq)
    if seq{i} == 3 %if you're supposed to substitute
        aligned{2,i} = X{xcount};
        aligned{1,i} = Y{ycount};
        xcount = xcount + 1;
        ycount = ycount + 1;
    elseif seq{i} == 2 %if you're supposed to insert
        aligned{2,i} = ' ';
        aligned{1,i} = Y{ycount};
        ycount = ycount + 1;
    elseif seq{i} == 1 %if you're supposed to delete
        aligned{2,i} = X{xcount};
        aligned{1,i} = ' ';
        xcount = xcount + 1;
    end
end
end
