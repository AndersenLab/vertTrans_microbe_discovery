import pandas as pd
import matplotlib.pyplot as plt


data = {'Power': [36.4, 44.4, 56, 73.68, 66.67, 58.8],
        'FDR': [63.51, 55.5, 44, 26.32, 33.3, 41.2],
        'Percent k-mers': [1, 3, 5, 10, 12, 15]}


PowerByFDR = pd.DataFrame(data)

plt.style.use("ggplot")

fig, ax1 = plt.subplots(figsize=(10, 6))

ax1.plot(PowerByFDR['Percent k-mers'], PowerByFDR['Power'], color='firebrick', marker='o', label='Power')
ax1.set_xlabel("k-mer percent cutoff", size=16, fontweight='bold', color = 'black')
ax1.set_xlim(0,16)
ax1.set_ylabel("Power (%)", color='firebrick', size=15, fontweight='bold')
ax1.set_ylim(20,80)
ax1.tick_params(axis='y', labelcolor='firebrick')

ax2 = ax1.twinx() #create a second y-axis on the same plot
ax2.plot(PowerByFDR['Percent k-mers'], PowerByFDR['FDR'], color='dodgerblue', marker='o', label='FDR')
ax2.set_ylabel("False Discovery Rate (FDR) (%)", color='dodgerblue', size=15, fontweight='bold')
ax2.set_ylim(20,80)
ax2.tick_params(axis='y', labelcolor='dodgerblue')

plt.title("Power and FDR based on % k-mer cutoff", size=18, fontweight='bold', color = 'black')
fig.tight_layout() 

plt.show()
# fig.savefig('/Users/lanceoconnor/Desktop/JohnsHopkins/ANDERSEN_THESIS/projects/pathogenDiscovery_SDSU_Anupama/plots/c_elegans/microsporidia_control/Power_FDR_kmer_cutoff.png', dpi=900)




