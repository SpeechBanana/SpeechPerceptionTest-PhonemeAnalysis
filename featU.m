function F = featU(mat,f)
% F = conversion of phoneme matrix into a feature matrix.
% mat = phoneme matrix
% f = categorization of phonemes to desired feature
%       NOTE - rows of f and mat should correspond
upper = max(f);
F = zeros(upper);

for i = 1:upper
for j = 1:upper
  a = find(f == i);
  b = find(f == j);
  F(i,j) = sum(sum(mat(a,b)));
end
end

% add unclassified column to feature matrix if it exists in phoneme matrix

%disp(size(mat,2))
%disp(length(f))
if size(mat,2) == length(f)+1
    %disp("unclassified column exists")
    v = zeros(upper,1);
    for i = 1:upper
        a = find(f == i);
        v(i) = sum(mat(a,end));
    end
    F(:,end+1) = v;
end