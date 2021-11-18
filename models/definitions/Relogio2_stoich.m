function S=Relogio2_stoich(p,force)

%Variables: 1 'CLOCK/BMAL1', 2 'PER*N/CRYN ',  3 'PERN/CRYN', 4 'BMAL_N', 5 'Rev-erb (Nuclear)', 6 'Ror (nuclear)', 7 'Per', 8 'Cry', 9 'Rev-erb',
%10 'Ror', 11 'Bmal', 12 'Cry(Cytoplasm)', 13 'Per (Cytoplasm)', 14 'Per* (Cytoplasm)', 15 'PERC*/CRYC', 16 'PERC/CRYC', 17 'Rev-erb (cytoplasmic)',
%18 'Ror (cytoplasmic)', 19 'Bmal (cytoplasmic)'

%Reference for reaction names - A. Relogio et al., Tuning the Mammalian
%Circadian Clock: Robust Synergy of Two  Loops, Plos Comp. Bio., 2011, suppl. materials, Text 1

   %1 2   3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 variables
S=[1  0   0 -1  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 1 CLOCK/BMAL-complex formation kf_x1
  -1  0   0  1  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 2 CLOCK/BMAL-complex dissociation kd_x1
  -1  0   0  0  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 3 degradation for nuclear proteins/ prot. complexes Clock/Bmal   d_x1  
   0  1   0  0  0  0  0  0  0  0 0  0  0  0 -1  0  0  0  0;% 4 import Per_C*/Cry_C ki_z4
   0  -1  0  0  0  0  0  0  0  0 0  0  0  0  1  0  0  0  0;% 5 export Per*N/Cry_N  ke_x2
   0  -1  0  0  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 6 degradation for nuclear proteins/ prot. complexes Per*_N/Cry_N d_x2  
   0  0   1  0  0  0  0  0  0  0 0  0  0  0  0 -1  0  0  0;% 7 import PER_C/CRY_C  ki_z5
   0  0  -1  0  0  0  0  0  0  0 0  0  0  0  0  1  0  0  0;% 8 export PER_N/CRY_N  ke_x3
   0  0  -1  0  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 9 degradation for nuclear proteins/ prot. complexes  PER_N/CRY_N d_x3  
   0  0   0  1  0  0  0  0  0  0 0  0  0  0  0  0  0  0  -1;%10 import BMAL_C  ki_z8
   0  0   0 -1  0  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 11 degradation for nuclear proteins/ prot. complexes BMAL_N       d_x7  
   0  0   0  0  1  0  0  0  0  0 0  0  0  0  0  0  -1 0  0;% 12 import Rev-erb_C  ki_z6
   0  0   0  0 -1  0  0  0  0  0 0  0  0  0  0  0  0  0  0;% 13 degradation for nuclear proteins/ prot. complexes REV_ERB_N    d_x5  
   0  0   0  0  0  1  0  0  0  0 0  0  0  0  0  0  0 -1  0;% 14 import Ror_C  ki_z7
   0  0   0  0  0 -1  0  0  0  0 0  0  0  0  0  0  0  0  0;% 15 degradation for nuclear proteins/ prot. complexes ROR_N        d_x6
   0  0   0  0  0  0  1  0  0  0 0  0  0  0  0  0  0  0  0;% 16 Per transcription V_1max 
   0  0   0  0  0  0 -1  0  0  0 0  0  0  0  0  0  0  0  0;% 17 degradation for mRNA Per d_y1  
   0  0   0  0  0  0  0  1  0  0 0  0  0  0  0  0  0  0  0;% 18 Cry transcription V_2max 
   0  0   0  0  0  0  0 -1  0  0 0  0  0  0  0  0  0  0  0;% 19 degradation for mRNA Cry d_y2  
   0  0   0  0  0  0  0  0  1  0 0  0  0  0  0  0  0  0  0;% 20 Rev-erb transcription  V_3max 
   0  0   0  0  0  0  0  0 -1  0 0  0  0  0  0  0  0  0  0;% 21 degradation for mRNA Rev-erb  d_y3  
   0  0   0  0  0  0  0  0  0  1 0  0  0  0  0  0  0  0  0;% 22 Ror transcription V_4max 
   0  0   0  0  0  0  0  0  0 -1 0  0  0  0  0  0  0  0  0;% 23 degradation for mRNA Ror d_y4  
   0  0   0  0  0  0  0  0  0  0 1  0  0  0  0  0  0  0  0;% 24 Bmal transcription V_5max 
   0  0   0  0  0  0  0  0  0  0 -1 0  0  0  0  0  0  0  0;% 25 degradation for mRNA Bmal d_y5 
   0  0   0  0  0  0  0  0  0  0 0  1  0  0  0  0  0  0  0;% 26 CRY_C production  k_p2 
   0  0   0  0  0  0  0  0  0  0 0  1  0  1 -1  0  0  0  0;% 27 PER_C*/CRY_C-complex dissociation kd_z4 
   0  0   0  0  0  0  0  0  0  0 0  1  1  0  0 -1  0  0  0;% 28 PER_C/CRY_C-complex dissociation kd_z5 
   0  0   0  0  0  0  0  0  0  0 0 -1 -1  0  0  1  0  0  0;% 29 PER_C/CRY_C-complex formation kf_z5 
   0  0   0  0  0  0  0  0  0  0 0 -1  0 -1  1  0  0  0  0;% 30 PER_C*/CRY_C-complex formation kf_z4 
   0  0   0  0  0  0  0  0  0  0 0 -1  0  0  0  0  0  0  0;% 31 degradation for cytoplasmic proteins Cry_C d_z1 
   0  0   0  0  0  0  0  0  0  0 0 0   1  0  0  0  0  0  0;% 32 PER_C production  k_p1 
   0  0   0  0  0  0  0  0  0  0 0 0   1 -1  0  0  0  0  0;% 33 PER_C* phosphorylation kd_phz3 
   0  0   0  0  0  0  0  0  0  0 0 0  -1  1  0  0  0  0  0;% 34 PER_C phosphorylation  kph_z2 
   0  0   0  0  0  0  0  0  0  0 0 0  -1  0  0  0  0  0  0;% 35 degradation for cytoplasmic proteins PER_C d_z2 
   0  0   0  0  0  0  0  0  0  0 0 0   0 -1  0  0  0  0  0;% 36 degradation for cytoplasmic proteins PER_C* d_z3 
   0  0   0  0  0  0  0  0  0  0 0 0   0  0 -1  0  0  0  0;% 37 degradation for cytoplasmic proteins PER_C*/CRY_C d_z4 
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0 -1  0  0  0;% 38 degradation for cytoplasmic proteins PER_C/CRY_C d_z5
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  1  0  0;% 39 Rev-erb_C production  k_p3 
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  -1 0  0;% 40 degradation for cytoplasmic proteins Rev-erb_C  d_z6
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  0  1  0;% 41 ROR_C production k_p4 
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  0 -1  0;% 42 degradation for for cytoplasmic proteins ROR_C d_z7
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  0  0  1;% 43 BMAL_C production  k_p5 
   0  0   0  0  0  0  0  0  0  0 0 0   0  0  0  0  0 0  -1;% 44 degradation for for cytoplasmic proteins BMAL_C d_z8
   ]';