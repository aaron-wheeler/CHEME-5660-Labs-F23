# load external packages and helper code -
_PATH_TO_ROOT = dirname(dirname(dirname(@__FILE__)))
include(joinpath(_PATH_TO_ROOT, "Include.jl"))

# compile functions -
discount_model = DiscreteCompoundingModel();
bill_dataset = MyTreasuryBillDataSet();
notes_bonds_dataset = MyTreasuryNotesAndBondsDataSet();
securityterm("7-Year")
p = plot(rand(2,2))