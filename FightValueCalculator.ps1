if ($PSVersionTable.PSEdition -ne "Core") {
	Write-Error "PowerShell Core is required to run this calculator.";
	exit 1;
}
Add-Type -TypeDefinition @"
public struct CreatureDamage {
	public CreatureDamage() { }
	public long Min = 0;
	public long Max = 0;
	public override string ToString() {
		return string.Format("[{0}, {1}]", Min, Max);
	}
}
public struct CreatureAbility {
	public CreatureAbility() { }
	public string Type = null;
	public string SubType = null;
	public long Value = 0;
	public override string ToString() {
		return string.Format("{0}[{1}]: {2}", Type, SubType, Value);
	}
}
public class CreatureAttribute {
	public CreatureAttribute() { }
	public long Attack = 0;
	public long Defense = 0;
	public CreatureDamage Damage = new CreatureDamage();
	public long DamageLow { set => Damage.Min = value; }
	public long DamageHigh { set => Damage.Max = value; }
	public long Level = 0;
	public long Health = 0;
	public long Speed = 0;
	public bool CanUpgrade = false;
	public System.Collections.Generic.Dictionary<string, CreatureAbility> Abilities = new System.Collections.Generic.Dictionary<string, CreatureAbility>();
}
"@

$AbilityBonus = @(
    @('NON_LIVING', 2, 2, 0, 0, 0),
    @('UNDEAD', 2, 2, 0, 0, 0),
    @('DRAGON_NATURE', 1, 1, 0, 0, 0),
    @('KING1', 1, 1, 0, 0, 0),
    @('KING2', 2, 2, 0, 0, 0),
    @('KING3', 3, 3, 0, 0, 0),
    @('FEARLESS', 5, 5, 0, 0, 0),
    @('NO_LUCK', 1, 1, 0, 0, 0),
    @('NO_MORALE', 1, 1, 0, 0, 0),
    @('SELF_MORALE', 2, 2, 0, 0, 0),
    @('SELF_LUCK', 2, 2, 0, 0, 0),
    @('FLYING', 5, 5, 0, 0, 0),
    @('FLYING_ARMY', 5, 5, 0, 0, 0),
    @('SHOOTER', 10, 10, 0, 0, 0),
    @('CHARGE_IMMUNITY', 2, 2, 0, 0, 0),
    @('ADDITIONAL_ATTACK', 0, 0, 0, 0, 0),
    @('UNLIMITED_RETALIATIONS', 10, 10, 0, 0, 0),
    @('ADDITIONAL_RETALIATION', 5, 5, 0, 0, 0),
    @('JOUSTING', 3, 3, 0, 0, 0),
    @('HATE', 1, 1, 0, 0, 0),
    @('SPELL_LIKE_ATTACK', 3, 3, 0, 0, 0),
    @('THREE_HEADED_ATTACK', 0, 0, 0, 0, 0),
    @('ATTACKS_ALL_ADJACENT', 0, 0, 0, 0, 0),
    @('TWO_HEX_ATTACK_BREATH', 0, 0, 0, 0, 0),
    @('RETURN_AFTER_STRIKE', 3, 3, 0, 0, 0),
    @('ENEMY_DEFENCE_REDUCTION', 0, 0, 0, 0, 0),
    @('GENERAL_DAMAGE_REDUCTION', 5, 5, 0, 0, 0),
    @('GENERAL_ATTACK_REDUCTION', 0, 0, 0, 0, 0),
    @('DEFENSIVE_STANCE', 5, 5, 0, 0, 0),
    @('NO_DISTANCE_PENALTY', 7, 7, 0, 0, 0),
    @('NO_MELEE_PENALTY', 5, 5, 0, 0, 0),
    @('NO_WALL_PENALTY', 3, 3, 0, 0, 0),
    @('FREE_SHOOTING', 10, 10, 0, 0, 0),
    @('BLOCKS_RETALIATION', 5, 5, 0, 0, 0),
    @('CATAPULT', 10, 10, 0, 0, 0),
    @('CHANGES_SPELL_COST_FOR_ALLY', 7, 7, 0, 0, 0),
    @('CHANGES_SPELL_COST_FOR_ENEMY', 7, 7, 0, 0, 0),
    @('SPELL_RESISTANCE_AURA', 5, 5, 0, 0, 0),
    @('HP_REGENERATION', 2, 2, 0, 0, 0),
    @('MANA_DRAIN', 3, 3, 0, 0, 0),
    @('MANA_CHANNELING', 3, 3, 0, 0, 0),
    @('LIFE_DRAIN', 5, 5, 0, 0, 0),
    @('DOUBLE_DAMAGE_CHANCE', 0, 0, 0, 0, 0),
    @('FEAR', 10, 10, 0, 0, 0),
    @('HEALER', 3, 3, 0, 0, 0),
    @('FIRE_SHIELD', 7, 7, 0, 0, 0),
    @('MAGIC_MIRROR', 4, 4, 0, 0, 0),
    @('ACID_BREATH', 3, 3, 0, 0, 0),
    @('DEATH_STARE', 10, 10, 0, 0, 0),
    @('SPELLCASTER', 5, 5, 0, 0, 0),
    @('ENCHANTER', 10, 10, 0, 0, 0),
    @('RANDOM_SPELLCASTER', 4, 4, 0, 0, 0),
    @('SPELL_AFTER_ATTACK', 3, 3, 0, 0, 0),
    @('SPELL_BEFORE_ATTACK', 3, 3, 0, 0, 0),
    @('CASTS', 0, 0, 0, 0, 0),
    @('SPECIFIC_SPELL_POWER', 0, 0, 0, 0, 0),
    @('CREATURE_SPELL_POWER', 0, 0, 0, 0, 0),
    @('CREATURE_ENCHANT_POWER', 0, 0, 0, 0, 0),
    @('DAEMON_SUMMONING', 7, 7, 0, 0, 0),
    @('ENCHANTED', 5, 5, 0, 0, 0),
    @('LEVEL_SPELL_IMMUNITY', 10, 10, 0, 0, 0),
    @('MAGIC_RESISTANCE', 5, 5, 0, 0, 0),
    @('SPELL_DAMAGE_REDUCTION', 2, 2, 0, 0, 0),
    @('MORE_DAMAGE_FROM_SPELL', -2, -2, 0, 0, 0),
    @('WATER_IMMUNITY', 2, 2, 0, 0, 0),
    @('EARTH_IMMUNITY', 2, 2, 0, 0, 0),
    @('AIR_IMMUNITY', 2, 2, 0, 0, 0),
    @('MIND_IMMUNITY', 2, 2, 0, 0, 0),
    @('SPELL_IMMUNITY', 1, 1, 0, 0, 0),
    @('DIRECT_DAMAGE_IMMUNITY', 10, 10, 0, 0, 0),
    @('RECEPTIVE', 3, 3, 0, 0, 0),
    @('POISON', 3, 3, 0, 0, 0),
    @('SLAYER', 3, 3, 0, 0, 0),
    @('BIND_EFFECT', 0, 0, 0, 0, 0),
    @('FORGETFULL', -7, -7, 0, 0, 0),
    @('NOT_ACTIVE', -10, -10, 0, 0, 0),
    @('ALWAYS_MINIMUM_DAMAGE', -5, -5, 0, 0, 0),
    @('ALWAYS_MAXIMUM_DAMAGE', 7, 7, 0, 0, 0),
    @('ATTACKS_NEAREST_CREATURE', -5, -5, 0, 0, 0),
    @('IN_FRENZY', 2, 2, 0, 0, 0),
    @('HYPNOTIZED', -10, -10, 0, 0, 0),

    @('const_raises_morale', 8, 8, 0, 0, 0)
);

function Read-CreatureJsonData {
	param ([string]$File);
	$Raw = Get-Content $File -ErrorAction Stop;
	$Trimed = New-Object System.Collections.Generic.List[string];
	foreach ($Line in $Raw) {
		$Result = ($Line -replace '//.*$','').Trim();
		if ($Result -ne "") {
			$Trimed.Add($Result);
		}
	}
	return $Trimed.ToArray() | ConvertFrom-Json -AsHashTable;
}
function Get-CharCount {
	param ([string]$Haystack, [char]$Needle);
	$Count = 0;
	foreach ($Char in $Haystack.ToCharArray()) {
		if ($Char -eq $Needle) {
			$Count++;
		}
	}
	return $Count;
}
function Read-CreatureTraitsData {
	param ([string]$File);
	$Raw = Get-Content $File -ErrorAction Stop;
	$Trimed = New-Object System.Collections.Generic.List[string];
	$Skip = 0;
	$Temp = "";
	foreach ($Line in $Raw) {
		if ($Skip -lt 2) {
			$Skip++; # Skip the header line
		}
		else {
			if ($Line -notmatch ',{24}') {
				$Temp += $Line;
				if ($(Get-CharCount -Haystack $Temp -Needle '"'[0]) % 2 -eq 0) {
					$Trimed.Add($Temp);
					$Temp = "";
				}
			}
		}
	}
	return $Trimed.ToArray() | ConvertFrom-Csv -Header @("Singular","Plural","Wood","Mercury","Ore","Sulfur","Crystal","Gems","Gold","FightValue","AIValue","Growth","HordeGrowth","HitPoints","Speed","Attack","Defense","DamageLow","DamageHigh","Shots","Spells","MapLow","MapHigh","AbilityText","Attributes");
}
function Get-DamageCoefficiency {
	param ([long]$Attack, [long]$Defense);
	$AverageSkill = 4;
	$a = $Attack + $AverageSkill;
	$d = $Defense + $AverageSkill;
	if ($a -gt $d) {
		return [Math]::Round(1 + [Math]::Min(($a - $d) * 0.05, 3))
	}
	else {
		return [Math]::Round(1 - [Math]::Min(($d - $a) * 0.025, 0.7))
	}
}
function Get-AttackDamage {
	param ([long]$Attack, [long]$DefenseReduction);
	$Result = 0;
	for ($i = 0; $i -lt 159; $i++) {
		$Result += Get-DamageCoefficiency -Attack $Attack -Defense $Traits[$i].Defense * (1 - $DefenseReduction);
	}
    $Result /= 159
	return [Math]::Round($Result)
}
function Get-DefenseDamage {
	param ([long]$Defense, [long]$AttackReduction);
    $Result = 0
	for ($i = 0; $i -lt 159; $i++) {
		$Result += Get-DamageCoefficiency -Attack $Traits[$i].Attack * (1 - $AttackReduction) -Defense $Defnese;
	}
    $Result /= 159
    return [Math]::Round($Result)
}
function Test-CreatureAbility {
	param ([CreatureAttribute]$CreatureAttribute, [string]$AbilityType);
	foreach ($Ability in $CreatureAttribute.Abilities.Values) {
		if ($Ability.Type -eq $AbilityType) {
			return $true;
		}
	}
	return $false;
}
function Get-CreatureAbilityValue {
	param ([CreatureAttribute]$CreatureAttribute, [string]$AbilityType);
	foreach ($Ability in $CreatureAttribute.Abilities.Values) {
		if ($Ability.Type -eq $AbilityType) {
			return $Ability.Value;
		}
	}
	return 0;
}
function Merge-CreatureAttribute {
	param ([CreatureAttribute]$CurrentAttribute, [Hashtable]$MergingData);
	if ($MergingData.ContainsKey("level")) { $CurrentAttribute.Level = $MergingData.level; }
	if ($MergingData.ContainsKey("attack")) { $CurrentAttribute.Attack = $MergingData.attack; }
	if ($MergingData.ContainsKey("defense")) { $CurrentAttribute.Defense = $MergingData.defense; }
	if ($MergingData.ContainsKey("hitPoints")) { $CurrentAttribute.Health = $MergingData.hitPoints; }
	if ($MergingData.ContainsKey("speed")) { $CurrentAttribute.Speed = $MergingData.speed; }
	if ($MergingData.ContainsKey("damage")) {
		$CurrentAttribute.DamageLow = $MergingData.damage.min;
		$CurrentAttribute.DamageHigh = $MergingData.damage.max;
	}
	if ($MergingData.ContainsKey("abilities")) {
		foreach ($AbilityName in $MergingData.abilities.Keys) {
			$AbilityData = $MergingData.abilities[$AbilityName];
			$Tmp = New-Object CreatureAbility;
			if ($AbilityData.ContainsKey("type")) {
				$Tmp.Type = $AbilityData.type;
			}
			else { $Tmp.Type = $AbilityName; }
			$Tmp.SubType = $AbilityData.subtype;
			$Tmp.Value = $AbilityData.val;
			$CurrentAttribute.Abilities[$AbilityName] = $Tmp;
		}
	}
	if ($MergingData.ContainsKey("upgrades")) { $CurrentAttribute.CanUpgrade = $true; }
}
function Get-CreatureAttributes {
	param ([string]$Name, [string]$CoreConfig, [string[]]$ModifierConfig);
	$Core = Read-CreatureJsonData -File $CoreConfig;
	if (-not $Core.ContainsKey($Name)) {
		throw "Incorrect core config file or creature name.";
	}
	$CreatureCoreData = $Core[$Name];

	[CreatureAttribute]$Attributes = New-Object CreatureAttribute

	if ($CreatureCoreData.ContainsKey("index")) {
		$Index = $CreatureCoreData.index;

		$Attributes.Attack = $Traits[$Index].Attack;
		$Attributes.Defense = $Traits[$Index].Defense;
		$Attributes.Health = $Traits[$Index].HitPoints;
		$Attributes.Speed = $Traits[$Index].Speed;
		$Attributes.DamageLow = $Traits[$Index].DamageLow;
		$Attributes.DamageHigh = $Traits[$Index].DamageHigh;
	}
	Merge-CreatureAttribute -CurrentAttribute $Attributes -MergingData $CreatureCoreData;

	$ModName = "core:" + $Name;
	foreach ($File in $ModifierConfig) {
		try {
			$CreatureData = Read-CreatureJsonData -File $File;
			if (-not $CreatureData.ContainsKey($ModName)) {
				throw "Incorrect core config file or creature name.";
			}
			Merge-CreatureAttribute -CurrentAttribute $Attributes -MergingData $CreatureData[$ModName];
		}
		catch {
			Write-Warning "$File does not contain requested data.";
		}
	}
	return $Attributes;
}
function Get-FightValue {
	param ([string]$Name, [string]$CoreConfig, [string[]]$ModifierConfig);
	$Attributes = Get-CreatureAttributes -Name $Name -CoreConfig $CoreConfig -ModifierConfig $ModifierConfig;

	$TwoHex = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "TWO_HEX_BREATH_ATTACK";
	$Poison = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "POISON";
	$Shooter = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "SHOOTER";
	$AcidBreath = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ACID_BREATH";
	$DoubleDamage = Test-CreatureAbility -CreatureAttribute $Attributes -Ability "DOUBLE_DAMAGE_CHANCE";
	$MinimumDamage = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ALWAYS_MINIMUM_DAMAGE";
	$MaximumDamage = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ALWAYS_MAXIMUM_DAMAGE";
	$AdditionalAttack = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ADDITIONAL_ATTACK";
	$ThreeHeadedAttack = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "THREE_HEADED_ATTACK";
	$AttacksAllAdjacent = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ATTACKS_ALL_ADJACENT";
	$EnemyDefenceReduction = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "ENEMY_DEFENCE_REDUCTION";
	$GeneralAttackReduction = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "GENERAL_ATTACK_REDUCTION";
	$Rebitrh = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "REBIRTH";
	$Regeneration = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "HP_REGENERATION";
	$FullRegeneration = Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType "FULL_HP_REGENERATION";

	$DamageMax = $Attributes.Damage.Max;
	$DamageMin = $Attributes.Damage.Min;
	$Health = $Attributes.Health;

	if ($MinimumDamage) { $DamageMax = $DamageMin; }
	if ($MaximumDamage) { $DamageMin = $DamageMax; }
	if ($ThreeHeadedAttack) { $DamageMax *= 3; }
	if ($AttacksAllAdjacent) { $DamageMax *= 6; }
	if ($AdditionalAttack) { $DamageMax *= 2; }
	if ($AdditionalAttack) { $DamageMax *= 2; }
	if ($TwoHex) { $DamageMax *= 2; }
	if ($AcidBreath) { $DamageMax += Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "ACID_BREATH"; }
	if ($Poison) { $DamageMax += Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "POISON"; }
	if ($FullRegeneration) { $Health *= 1.8; } # Roughly trear this as extra 80% max health.
	if ($Rebitrh) { $Health *= ((100 + $(Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "REBIRTH")) / 100.0); }
	if ($Regeneration) { $Health += $(Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "HP_REGENERATION") * 0.9; } # Add 90% of regeneration to Health
	if ($DoubleDamage) {
		$DoubleDamageChance = Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "DOUBLE_DAMAGE_CHANCE";
		if ($DoubleDamageChance -gt 0) {
			$DamageMin += $Attributes.Damage.Max;
		}
	}
	$DefenseReduction = 0;
	$AttackReduction = 0;
	if ($EnemyDefenseReduction) {
		$DefenseReduction = $(Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "ENEMY_DEFENCE_REDUCTION") / 100.0;
		if ($DefenseReduction -gt 1.0) { $DefenseReduction = 1.0; }
	}
	if ($GeneralAttackReduction) {
		$AttackReduction = $(Get-CreatureAbilityValue -CreatureAttribute $Attributes -AbilityType "GENERAL_ATTACK_REDUCTION") / 100.0;
		if ($AttackReduction -gt 1.0) { $AttackReduction = 1.0; }
	}

	$DamageFactor = 0.3; # Because we have the "Curse" spell, and sometimes the max damage is conditional.
	$ProtPowerFight = 0.57; # Less for Fight value
	$ProtPowerAI = 0.67; # More for AI value
	$FightRatio = 1;
	$AIRatio = 0.6;
	$AttackValue = $(Get-AttackDamage -Attack $Attributes.Attack -DefenseRedution $DefenseReduction) * ($DamageFactor * $DamageMax + (1 - $DamageFactor) * $DamageMin) * 50 + 1;
	$DefenseValue = (7 / $(Get-DefenseDamage -Defense $Attributes.Defense -AttackReduction $AttackReduction) + 1) * $Health + 1;
	
	function Get-Final {
		param ($AttackValue, $DefenseValue, $ProtPower, $Ratio);
		if ($AttackValue -eq 0) {
			return 0;
		}
		else {
			return [long]([Math]::Round([Math]::Sqrt($AttackValue) * [Math]::Pow($DefenseValue, $ProtPower) * $Ratio));
		}
	}
	$FinalFight = Get-Final -AttackValue $AttackValue -DefenseValue $DefenseValue -ProtPower $ProtPowerFight -Ratio $FightRatio;
	$FinalAI = Get-Final -AttackValue $AttackValue -DefenseValue $DefenseValue -ProtPower $ProtPowerAI -Ratio $AIRatio;

	foreach ($Bonus in $AbilityBonus) {
		if (Test-CreatureAbility -CreatureAttribute $Attributes -AbilityType $Bonus[0]) {
			$FinalFight = $FinalFight * ((100 + $Bonus[1]) / 100.0);
			$FinalAI = $FinalAI * ((100 + $Bonus[2]) / 100.0);
		}
	}

	if ($Attributes.Speed -gt 5) {
		if ($Attributes.Speed -le 10) {
			$FinalFight *= 1.05;
			$FinalAI *= 1.05;
		}
		elseif ($Attributes.Speed -le 20) {
			$FinalFight *= 1.10;
			$FinalAI *= 1.10;
		}
		else {
			$FinalFight *= 1.15;
			$FinalAI *= 1.15;
		}
	}

	return @{ FightValue = $FinalFight; AIValue = $FinalAI; };
}
if ($Traits -eq $null) {
	$TraitsFile = Read-Host -Prompt "CRTRAITS.txt"
	$Traits = Read-CreatureTraitsData -File $TraitsFile;
}
if ($VCMIDir -eq $null) {
	$VCMIDir = Read-Host -Prompt "VCMI DIR"
}
while ($true) {
	Write-Host -NoNewLine ": "
	$Raw = Read-Host;
	try {
		$Query = $Raw.Substring(1).Trim().Split(":");
		$Town = $Query[0];
		$Creature = $Query[1];
		if ($Raw[0] -eq "?") {
			try {
				$Attribute = Get-CreatureAttributes -Name $Creature -CoreConfig "$VCMIDir/config/creatures/$Town.json" -ModifierConfig @("XeroDiff/Content/Config/$Town/Creatures.json");
				function Write-Attribute {
					param([string]$Attribute, [object]$Value);
					$Color = [Console]::ForegroundColor;
					[Console]::Write(($Attribute.ToString() + ":").PadRight(9));
					[Console]::ForegroundColor = 12;
					[Console]::Write($Value.ToString());
					[Console]::ForegroundColor = $Color;
					[Console]::WriteLine();
                     }
				if ($Attribute.CanUpgrade) {
					Write-Attribute -Attribute "LEVEL" -Value $($Attribute.Level.ToString() + " (Upgradable)");
				}
				else {
					Write-Attribute -Attribute "LEVEL" -Value $Attribute.Level;
				}
				Write-Attribute -Attribute "HEALTH" -Value $Attribute.Health;
				Write-Attribute -Attribute "ATTACK" -Value $Attribute.Attack;
				Write-Attribute -Attribute "DEFENSE" -Value $Attribute.Defense;
				Write-Attribute -Attribute "DAMAGE" -Value $Attribute.Damage;
				Write-Attribute -Attribute "SPEED" -Value $Attribute.Speed;
				Write-Host $("ABILITY [" + $Attribute.Abilities.Count  + "]:");
				$MaxLength = 0;
				foreach ($AbilityId in $Attribute.Abilities.Keys) {
					if ($AbilityId.Length -gt $MaxLength) {
					$MaxLength = $AbilityId.Length;
					}
				}
				function Write-Ability {
					param([int]$Pad, [string]$Id, [CreatureAbility]$Ability);
					$Color = [Console]::ForegroundColor;
					[Console]::Write("  * " + $Id.Insert($Id.Length, ":").PadRight($Pad));
					[Console]::ForegroundColor = 10;
					[Console]::Write($Ability.Type.ToString());
					if ($Ability.SubType -ne $null) {
						[Console]::ForegroundColor = 13;
						[Console]::Write(" " + $Ability.SubType.ToString());
					}
					[Console]::ForegroundColor = $Color;
					[Console]::Write(": ");
					[Console]::ForegroundColor = 12;
					[Console]::Write($Ability.Value);
					[Console]::ForegroundColor = $Color;
					[Console]::WriteLine();
                     }
				foreach ($AbilityId in $Attribute.Abilities.Keys) {
					Write-Ability -Pad $($MaxLength + 2) -Id $AbilityId -Ability $Attribute.Abilities[$AbilityId];
				}
			}
			catch { Write-Host "FAILED"; }
		}
		elseif ($Raw[0] -eq "!") {
			try {
				$Result = $(Get-FightValue -Name $Creature -CoreConfig "$VCMIDir/config/creatures/$Town.json" -ModifierConfig @("XeroDiff/Content/Config/$Town/Creatures.json"));
				function Write-Result {
					param([Hashtable]$Result);
					$Color = [Console]::ForegroundColor;
					[Console]::Write("Fight Value: ");
					[Console]::ForegroundColor = 12;
					[Console]::Write($Result["FightValue"].ToString("0.00"));
					[Console]::ForegroundColor = $Color;
					[Console]::WriteLine();
					[Console]::Write("AI Value:    ");
					[Console]::ForegroundColor = 12;
					[Console]::Write($Result["AIValue"].ToString("0.00"));
					[Console]::ForegroundColor = $Color;
					[Console]::WriteLine();
				}
				Write-Result -Result $Result
			}
			catch { Write-Host "FAILED"; }
		}
		else {
			Write-Host "UNKNOWN";
		}
	}
	catch { Write-Host "INVALID"; }
}
