function [ output_args ] = ppReadParadigm(dir)

%.txt to String
txt='epi_rft swa 95 65epi_bart swa 270 190epi_edt swa 245 170epi_emp swa 260 180epi_mr_r1 swa 213 150epi_mr_r2 swa 213 150epi_sst_r1 swa 190 135epi_sst_r2 swa 190 135epi_rs swa 258 180epi_attract_other swa 279 200epi_attract_self swa 279 200t1_mpr_sag_07mm_optimised - 1 25';

parameters=regexpi(txt, 'epi_edt (?<type>[a-z]*) (?<amount>[\d]*)', 'names');
type=parameters.type;
amount=parameters.amount;

if type(1:1)=='-'
    
else
   %search (type,'vols.nii');
   %if search==0
       % do /scripts/(type, '.m')
       %write file: ('missing .nii for',type, '...processing') 
            %if search (type, '.m') ==0
                %%write file: ('missing .m for',type, ' processing cancelled')
             %end
   %end
end

