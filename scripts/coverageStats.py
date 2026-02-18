import matplotlib.pyplot as plt
import pandas as pd
import sys
from scipy.stats import mannwhitneyu
import numpy as np

plt.rcParams['font.family'] = 'Arial' 

species = sys.argv[1]
NA_strainCov_path = f"/Users/lanceoconnor/Desktop/JohnsHopkins/ANDERSEN_THESIS/projects/pathogenDiscovery_SDSU_Anupama/processed_data/{species}/wild_strains/seqCoverage/{species}_NA_10perc_strainList_aveCoverage.csv"
allGeneraCov_path = f"/Users/lanceoconnor/Desktop/JohnsHopkins/ANDERSEN_THESIS/projects/pathogenDiscovery_SDSU_Anupama/processed_data/{species}/wild_strains/seqCoverage/{species}_allGenera_10perc_strainList_aveCoverage.csv"
stringentGeneraCov_path = f"/Users/lanceoconnor/Desktop/JohnsHopkins/ANDERSEN_THESIS/projects/pathogenDiscovery_SDSU_Anupama/processed_data/{species}/wild_strains/seqCoverage/{species}_restrictedGenera_10perc_strainList_aveCoverage.csv"

NA_strainCov = pd.read_csv(NA_strainCov_path)
allGeneraCov = pd.read_csv(allGeneraCov_path)
stringentGeneraCov = pd.read_csv(stringentGeneraCov_path)

stat_allGen, p_val_allGen = mannwhitneyu(NA_strainCov['coverage'], allGeneraCov['coverage'], alternative='two-sided')
# print(f'Between NA strains and all genera strains: stat={stat_allGen}, p-value={p_val_allGen}')

stat_stringentGen, p_val_stringentGen = mannwhitneyu(NA_strainCov['coverage'], stringentGeneraCov['coverage'], alternative='two-sided')
# print(f'Between NA strains and stringent genera strains: stat={stat_stringentGen}, p-value={p_val_stringentGen}')

fig, axes = plt.subplots(1, 2, figsize=(10, 12))
ax1 = axes[0]
ax2 = axes[1]

NAstrainCount = len(NA_strainCov['strain_name'])
genStrainCount = len(allGeneraCov['strain_name'])
stringStrainCount = len(stringentGeneraCov['strain_name'])

max_val = max(NA_strainCov['coverage'].max(), allGeneraCov['coverage'].max(), stringentGeneraCov['coverage'].max())
min_val = min(NA_strainCov['coverage'].min(), allGeneraCov['coverage'].min(), stringentGeneraCov['coverage'].min())
bins = np.linspace(min_val, max_val, 30)  #30 bins

# between NA and all genera identified
ax1.hist(NA_strainCov['coverage'], bins=bins, color='dodgerblue', alpha=0.5, label=f'NA strains ({NAstrainCount})')
ax1.hist(allGeneraCov['coverage'], bins=bins, color='darkgreen', alpha=0.5, label=f'Strains with all genera ({genStrainCount})')

ax1.set_ylabel("Number of strains", size=15, fontweight='bold', color='black')
ax1.set_xlabel("Average Coverage per Strain", size=16, fontweight='bold', color='black')
ax1.legend(loc='upper right')
ax1.text(0.5, 0.8, f'p-value: {p_val_allGen:.3f}', transform=ax1.transAxes, fontsize=12, verticalalignment='top')

# between NA and genera of potential interest (fluff removed)
ax2.hist(NA_strainCov['coverage'], bins=bins, color='dodgerblue', alpha=0.5, label=f'NA strains ({NAstrainCount})')
ax2.hist(stringentGeneraCov['coverage'], bins=bins, color='yellowgreen', alpha=0.5, label=f'Strains with restricted genera ({stringStrainCount})')

ax2.set_xlabel("Average Coverage per Strain", size=16, fontweight='bold', color='black')
ax2.legend(loc='upper right')
ax2.text(0.5, 0.8, f'p-value: {p_val_stringentGen:.3f}', transform=ax2.transAxes, fontsize=12, verticalalignment='top')

fig.suptitle('C. elegans', size=18, fontweight='bold', color='black', fontstyle = 'italic')
fig.tight_layout(rect=[0, 0.03, 1, 0.99])

plt.show()
fig.savefig(f'/Users/lanceoconnor/Desktop/JohnsHopkins/ANDERSEN_THESIS/projects/pathogenDiscovery_SDSU_Anupama/plots/{species}/wild_strains/coverageStats.png', dpi=900)
