# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Athena.Repo.insert!(%Athena.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Athena.Inventory

{:ok, event_aufgetischt} = create_event(%{name: "Aufgetischt SG 2020"})

{:ok, location_laurenzen} = create_location(event_aufgetischt, %{name: "Laurenzenkirche"})
{:ok, location_gallus_strasse} = create_location(event_aufgetischt, %{name: "Gallusstrasse"})
{:ok, location_vadian} = create_location(event_aufgetischt, %{name: "Vadian Denkmahl"})
{:ok, location_gallus_platz} = create_location(event_aufgetischt, %{name: "Gallusplatz"})
{:ok, location_cocktail_caravan} = create_location(event_aufgetischt, %{name: "Cocktail Caravan"})
{:ok, location_buskers_bistro} = create_location(event_aufgetischt, %{name: "Buskers Bistro"})
{:ok, location_backstage} = create_location(event_aufgetischt, %{name: "Backstage"})

{:ok, item_group_beer} = create_item_group(event_aufgetischt, %{name: "Bier"})
{:ok, item_group_wine} = create_item_group(event_aufgetischt, %{name: "Wein"})
{:ok, item_group_cups} = create_item_group(event_aufgetischt, %{name: "Becher"})
{:ok, item_group_softdrinks} = create_item_group(event_aufgetischt, %{name: "Softdrinks"})
{:ok, item_group_other} = create_item_group(event_aufgetischt, %{name: "Diverses"})

{:ok, item_lager} = create_item(item_group_beer, %{name: "Lager hell", unit: "Fass"})
{:ok, item_lager_big} = create_item(item_group_beer, %{name: "Lager hell", unit: "50L Fass"})
{:ok, item_lager_can} = create_item(item_group_beer, %{name: "Lager hell", unit: "24 Dosen"})

{:ok, item_edelspez_bottle} =
  create_item(item_group_beer, %{name: "Edelspez Premium", unit: "24 Flaschen"})

{:ok, item_kloesti} =
  create_item(item_group_beer, %{name: "St. Galler Klosterbräu", unit: "Fass"})

{:ok, item_kloesti_bottle} =
  create_item(item_group_beer, %{name: "St. Galler Klosterbräu", unit: "24 Flaschen"})

{:ok, item_empty_ceg} = create_item(item_group_beer, %{name: "Leer", unit: "Fass", inverse: true})

{:ok, item_prosecco} =
  create_item(item_group_wine, %{name: "Prosecco Noia Brut", unit: "6 Flachen"})

{:ok, item_rotwein} =
  create_item(item_group_wine, %{name: "Merlot Irti Colli", unit: "6 Flaschen"})

{:ok, item_weisswein} =
  create_item(item_group_wine, %{name: "Sauvignon Blanc Stein am Rhein", unit: "6 Flaschen"})

{:ok, item_chardonnay} = create_item(item_group_wine, %{name: "Chardonnay", unit: "6 Flaschen"})

{:ok, item_petit_arvinne} =
  create_item(item_group_wine, %{name: "Petit Arvine", unit: "6 Flaschen"})

{:ok, item_adelheidy} =
  create_item(item_group_wine, %{name: "Adelheid Pinot/Cabernet", unit: "6 Flaschen"})

{:ok, item_zweigelt} =
  create_item(item_group_wine, %{name: "Zweigelt Barrique", unit: "6 Flaschen"})

{:ok, item_bliss} = create_item(item_group_wine, %{name: "Bliss Perlwein", unit: "6 Flaschen"})

{:ok, item_water_flat} =
  create_item(item_group_softdrinks, %{name: "Appenzell Mineral still", unit: "24 PET"})

{:ok, item_water_gas} =
  create_item(item_group_softdrinks, %{name: "Appenzell Mineral laut", unit: "24 PET"})

{:ok, item_cola} = create_item(item_group_softdrinks, %{name: "Goba Cola", unit: "24 PET"})
{:ok, item_citro} = create_item(item_group_softdrinks, %{name: "Goba Citro", unit: "24 PET"})

{:ok, item_iisfee} =
  create_item(item_group_softdrinks, %{name: "Appenzeller Flauder iisfee", unit: "24 PET"})

{:ok, item_mint} =
  create_item(item_group_softdrinks, %{name: "Appenzeller Flauder Minz", unit: "24 PET"})

{:ok, item_flauder} =
  create_item(item_group_softdrinks, %{name: "Flauder Original", unit: "24 PET"})

{:ok, item_shorley} =
  create_item(item_group_softdrinks, %{name: "Möhl Shorley Culinarium", unit: "24 PET"})

{:ok, item_bierbecher} = create_item(item_group_cups, %{name: "MWV-Trinkbecher", unit: "Kiste"})
{:ok, item_coffeemug} = create_item(item_group_cups, %{name: "MWV-kafitasse", unit: "Kiste"})
{:ok, item_weinkelch} = create_item(item_group_cups, %{name: "MWV-Weiskelch", unit: "Kiste"})
{:ok, item_whiskyglass} = create_item(item_group_cups, %{name: "MWV-Whisky", unit: "Kiste"})
{:ok, item_event_becher} = create_item(item_group_cups, %{name: "MWV-Eventbecher", unit: "Kiste"})
{:ok, item_leere_kiste} = create_item(item_group_cups, %{name: "Leih-Boxe", unit: "Kiste"})

{:ok, item_dreckige_kiste} =
  create_item(item_group_cups, %{name: "Dreckig", unit: "Kiste", inverse: true})

{:ok, item_eis} = create_item(item_group_other, %{name: "Eis", unit: "Sack"})
{:ok, item_gas} = create_item(item_group_other, %{name: "Kohlensäure", unit: "Flasche"})

initial_supply = [
  # Cup & More - GV Gallusplatz
  %{
    location: location_gallus_platz,
    supply: [
      {5, item_weinkelch},
      {5, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - GV Gallusstrasse
  %{
    location: location_gallus_strasse,
    supply: [
      {5, item_weinkelch},
      {5, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - GV Laurenzen
  %{
    location: location_laurenzen,
    supply: [
      {5, item_weinkelch},
      {5, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - GV Multertor
  %{
    location: location_gallus_platz,
    supply: [
      {5, item_weinkelch},
      {5, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - GV Hinterlauben
  %{
    location: location_laurenzen,
    supply: [
      {3, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - GV Marktgasse
  %{
    location: location_vadian,
    supply: [
      {5, item_weinkelch},
      {5, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - Buskers Bistro
  %{
    location: location_buskers_bistro,
    supply: [
      {1, item_coffeemug},
      {5, item_weinkelch},
      {3, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - Backstage
  %{
    location: location_buskers_bistro,
    supply: [
      {2, item_weinkelch},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - Cocktail Caravan
  %{
    location: location_cocktail_caravan,
    supply: [
      {8, item_whiskyglass},
      {2, item_event_becher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste},
      {10, item_eis}
    ]
  },
  # Cup & More - Weinbar Grüningerplatz
  %{
    location: location_laurenzen,
    supply: [
      {5, item_weinkelch},
      {1, item_bierbecher},
      {1, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Cup & More - Depotrückgabe
  %{
    location: location_laurenzen,
    supply: [
      {10, item_leere_kiste},
      {0, item_dreckige_kiste}
    ]
  },
  # Goba Sponsoring
  %{
    location: location_laurenzen,
    supply: [
      {26, item_water_flat},
      {18, item_water_gas},
      {27, item_citro},
      {9, item_cola},
      {9, item_iisfee},
      {9, item_flauder},
      {9, item_mint}
    ]
  },
  # Schüga Backstage
  %{
    location: location_backstage,
    supply: [
      {36, item_lager_can},
      {1, item_edelspez_bottle},
      {1, item_kloesti_bottle},
      {0, item_empty_ceg}
    ]
  },
  # Schüga Bierstand Hinterlaube
  %{
    location: location_laurenzen,
    supply: [
      {2, item_lager_big},
      {3, item_kloesti},
      {1, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga Gallusplatz Getränkestand
  %{
    location: location_gallus_platz,
    supply: [
      {12, item_lager},
      {15, item_kloesti},
      {6, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga Gallusplatz Kühlwagen
  %{
    location: location_gallus_platz,
    supply: [
      {90, item_lager},
      {30, item_kloesti},
      {18, item_water_gas},
      {18, item_water_flat},
      {18, item_citro},
      {18, item_cola},
      {18, item_iisfee},
      {9, item_mint},
      {18, item_flauder},
      {18, item_shorley},
      {2, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga Gallusplatz Ketränkestand
  %{
    location: location_gallus_platz,
    supply: [
      {12, item_lager},
      {15, item_kloesti},
      {6, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga KW Logistik
  %{
    location: location_laurenzen,
    supply: [
      {150, item_lager},
      {30, item_kloesti},
      {18, item_water_gas},
      {18, item_water_flat},
      {18, item_citro},
      {18, item_cola},
      {18, item_iisfee},
      {9, item_mint},
      {18, item_flauder},
      {18, item_shorley},
      {6, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga KW Gallusstrasse
  %{
    location: location_gallus_strasse,
    supply: [
      {30, item_lager},
      {15, item_kloesti},
      {9, item_water_gas},
      {9, item_water_flat},
      {9, item_citro},
      {9, item_cola},
      {9, item_iisfee},
      {9, item_mint},
      {9, item_flauder},
      {9, item_shorley},
      {2, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga KW Vadian
  %{
    location: location_vadian,
    supply: [
      {45, item_lager},
      {15, item_kloesti},
      {9, item_water_gas},
      {9, item_water_flat},
      {9, item_citro},
      {9, item_cola},
      {9, item_iisfee},
      {9, item_mint},
      {9, item_flauder},
      {9, item_shorley},
      {2, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga Laurenzen
  %{
    location: location_laurenzen,
    supply: [
      {12, item_lager},
      {15, item_kloesti},
      {2, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga GV Vadian
  %{
    location: location_vadian,
    supply: [
      {10, item_lager},
      {5, item_kloesti},
      {4, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Schüga GV Webergasse
  %{
    location: location_gallus_platz,
    supply: [
      {6, item_lager},
      {15, item_kloesti},
      {2, item_gas},
      {0, item_empty_ceg}
    ]
  },
  # Weinstein
  %{
    location: location_laurenzen,
    supply: [
      {34, item_prosecco},
      {34, item_weisswein},
      {6, item_petit_arvinne},
      {6, item_chardonnay},
      {34, item_rotwein},
      {6, item_adelheidy},
      {6, item_zweigelt},
      {4, item_bliss},
      {0, item_empty_ceg}
    ]
  }
]

for %{location: location, supply: supplies} <- initial_supply, {amount, item} <- supplies do
  {:ok, _movement} =
    create_movement(item, %{destination_location_id: location.id, amount: amount})
end
