function [phoxyz, diphOffset] = phoxyz_map()
% PHOXYZ_MAP  Plot coordinates for the three phoneme-accuracy panels.
%   Replaces phoxyz.mat (kept in the repo only for reference).
%
%   phoxyz      containers.Map, phoneme -> coordinate
%                 vowels:     [place height]
%                             place 1..7  = front..back
%                             height 1..5 = low..high
%                 consonants: [place manner voicing]
%                             place   1 Bilabial  2 Labiodental 3 Dental
%                                     4 Alveolar  5 Postalveolar 6 Palatal
%                                     7 Velar     8 Glottal
%                             manner  1 Sonorant 2 Fricative 3 Affricate
%                                     4 Stop     5 Nasal
%                             voicing 1 = voiced, -1 = unvoiced
%   diphOffset  containers.Map, diphthong -> [place height] of its offset.
%               Diphthongs are plotted at their onset with an arrow
%               pointing toward the offset.
%
%   Changes from phoxyz.mat (Oct 2026):
%     TH  voiced -> unvoiced, DH unvoiced -> voiced (were swapped)
%     HH  alveolar [4 2] (hidden under S) -> glottal [8 2]
%     Y   [5 1] (hidden under R) -> palatal [6 1]
%     CH, JH alveolar -> postalveolar; G, K, NG velar column 6 -> 7
%     UH  mid central [4 3] -> high back [6 5]
%     ER  [3 2] -> mid central [4 3]
%     AY, AW, OY plotted at onset (AY [3 1], AW [5 1], OY [6 2]) with arrows

cons = { ...
    'B',  [1 4  1];  'P',  [1 4 -1];  'M',  [1 5  1];  'W',  [1 1  1]; ...
    'F',  [2 2 -1];  'V',  [2 2  1]; ...
    'TH', [3 2 -1];  'DH', [3 2  1]; ...
    'D',  [4 4  1];  'T',  [4 4 -1];  'N',  [4 5  1];  'S',  [4 2 -1]; ...
    'Z',  [4 2  1];  'L',  [4 1  1]; ...
    'CH', [5 3 -1];  'JH', [5 3  1];  'SH', [5 2 -1];  'ZH', [5 2  1]; ...
    'R',  [5 1  1]; ...
    'Y',  [6 1  1]; ...
    'G',  [7 4  1];  'K',  [7 4 -1];  'NG', [7 5  1]; ...
    'HH', [8 2 -1]};

vow = { ...
    'IY', [1 5];  'IH', [2 5];  'EY', [1 4];  'EH', [1 3];  'AE', [1 1]; ...
    'ER', [4 3];  'AH', [5 3]; ...
    'UW', [7 5];  'UH', [6 5];  'OW', [7 4];  'AO', [7 2];  'AA', [7 1]; ...
    'AY', [3 1];  'AW', [5 1];  'OY', [6 2]};

entries = [cons; vow];
phoxyz = containers.Map(entries(:,1)', entries(:,2)');

diphOffset = containers.Map({'AY','AW','OY'}, {[2 5], [6 5], [2 5]});
end
