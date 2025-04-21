from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
import pandas as pd
import time
import re

#############
# modify the three lines below and let 'er rip

rtn_team_numbers = [*range(36, 57), *range(58, 67), *range(68, 83), 163, 156, 154, 128, 155, 164, 174] # these are all the team ids for 2025
# rtn_team_numbers = [*range(1, 35), *range(36, 57), *range(58, 67), *range(68, 83), 163, 156, 154, 128, 155, 164, 174] # these are all the team ids for 2025
years = [2025] # make this a list!

#############

# Function to scrape data for a specific team page
def scrape_team_data(driver, team_name, meetnum, year):
    soup = BeautifulSoup(driver.page_source, "html.parser")
    # Extract the data from the table

    table = soup.find("div", {"class": "teamsbox"})
    rows = table.find_all("div", {"class": "rt-tr"})

    try:
        has_meet_title = soup.find("h2")
        meet_title = has_meet_title.get_text(strip=True)
    except:
        meet_title = "no meet title"

    meet_info_tags = soup.find_all("p", class_="meet-info")

    # Initialize variables to store date and host
    date = None
    host = None

    # Iterate over each <p> tag
    for tag in meet_info_tags:
        # Get the text of the <p> tag
        text = tag.get_text(strip=True)
        
        # Check if the text contains "Date:" and extract the date
        if text.startswith("Date:"):
            date = text.replace("Date:", "", 1).strip()
        
        # Check if the text contains "Host:" and extract the host
        elif text.startswith("Host:"):
            host = text.replace("Host:", "", 1).strip()
    
    team_data = ["","","","","","",""]
    for row in rows:
        columns = row.find_all("div", {"class": "rt-td"})
        data = [team_name] + [year] + [meetnum] + [meet_title] + [date] + [host] + [column.text.strip() for column in columns]
        team_data.append(data)

    return team_data

# Function to scrape data for all teams (only page 1)
def scrape_all_teams(driver, meetnum, year, team):
    teams = ["","","","","",""]
    # Find and click the "Teams" button
    teams_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "teambtn")))
    teams_button.click()

    meetnum = meetnum
    team = team
    
    # Wait for the table to load (modify the wait duration as needed)
    time.sleep(1)

    soup = BeautifulSoup(driver.page_source, "html.parser")

    team_buttons = soup.find_all("button", id=lambda x: x and "team" in x)

    # Extract the text from each button
    team_button_texts = [button.get_text() for button in team_buttons]
    corrected_team_count = len(team_button_texts) - 1

    for num in range(corrected_team_count): 
        team_id = f"team{num}"
        
        team_button = WebDriverWait(driver,1).until(EC.presence_of_element_located((By.ID, team_id)))
        team_button.click()

        team_name = team_button.text.strip()

        if f"{team_name}" == f"{team}":
            team_data = scrape_team_data(driver, team_name, meetnum, year)  # Assuming there is only one page
            teams.append(team_data)
        else:
            continue

    return teams

# Main function
def main():
    for rtn_team_number in rtn_team_numbers:
        for year in years:
            # Set up the Selenium webdriver
            driver = webdriver.Firefox()

            df = pd.DataFrame(columns=["team", "year", "meetnum", "meettitle", "date", "host", "nothinghere", "gymnast", "vault", "bars", "beam", "floor", "allaround"])

            meetnum = 0

            season_url = f"https://roadtonationals.com/results/teams/dashboard/{year}/{rtn_team_number}"

            driver.get(season_url)
            time.sleep(6)

            yoink = BeautifulSoup(driver.page_source, "html.parser")

            select_team = Select(driver.find_element(By.ID,"team_filter"))
            select_team.select_by_value(f"{rtn_team_number}")
            team = select_team.first_selected_option.text
            print(team)

            # Find all <a> tags with text "View"
            view_links = yoink.find_all("a", string="View")

            # Extract the URLs and store them in a list
            view_links_list = [link["href"] for link in view_links]

            if view_links_list == []: # try again if it failed the load, which it occasionally fails
                driver.get(season_url)
                time.sleep(4)
                yoink = BeautifulSoup(driver.page_source, "html.parser")
                view_links = yoink.find_all("a", string="View")
                view_links_list = [link["href"] for link in view_links]
                # del view_links_list[-1]
            
            # del view_links_list[-1] # use this if the page has a weird scoreless meet, like the last meet on https://roadtonationals.com/results/teams/dashboard/2017/40

            # Replace with the actual URL of the page containing the buttons
            for link in view_links_list:
                time.sleep(1)
                meetnum = meetnum + 1
                meet_url = f"https://roadtonationals.com{link}"
                # Get the main page content
                driver.get(meet_url)
                # Scrape data for all teams on page 1
                all_teams_data = scrape_all_teams(driver, meetnum, year, team)
            
                for team_data in all_teams_data:
                    for row in team_data:
                        if len(row) == len(df.columns):
                            df = df._append(pd.Series(row, index=df.columns), ignore_index=True)
                        else:
                            continue  # Skip this row if the length doesn"t match
            driver.quit()
        
            # Print the dataframe
            print(df)
            df = df.drop(columns=["nothinghere", "allaround"])

            scrape = f"C:/Users/toom/Desktop/uneven_bars/data/scrapes/{team}_{year}.csv"
            df.to_csv(scrape, index=False, encoding="utf-8")
    print("mission accomplished!!")


if __name__ == "__main__":
    main()

