# Implemented Clock Models

## F2014

### Papers
[Battle et al., 2024](https://doi.org/10.1016/j.molp.2024.07.007)

### Stats

114 parameters 
35 variables

### Data Sets
Sets of parameter data obtained by fitting the model to experimental data. Each set of parameter configuration can be selected by specifying a value between 1 - 8 to the _set_ argument for `loadParameters(genotype, set)`.

### Supported Mutant Variation
Genetic variation that can be applied by specifying a set of strings to the _genotype_ argument for `loadParameters(genotype, set)`.

| Variant Flags | Altered Parameters | Notes |
| ---- | ---- | ----- |
| cca1         | f5         |       |
| cca lhy      | n1, q1     |       |
| CCA10X       | n1, q1     |       |
| elf3         | p16        | ELF3 protein production. <br/>(mRNA is not directly affected) |
| YHB          | yhb        |       |
