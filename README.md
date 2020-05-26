# Template
![Build](https://github.com/mddeepaksoni/template/workflows/Build/badge.svg)

This repository is mean't to serve as a general template for how to set up new repositories in @mddeepaksoni. In general, setting up a new repository should take only a few minutes; use this repository as a way of finding example files, and use the following checklist to ensure that you've set up the repository correctly.

## Install
Please follow the below `bash` instructions to create repository using this template repository. Please make sure to complete the checklist.
1. Create repository
    Using github user interface using [template repository](https://github.com/mddeepaksoni/template) or
    ```bash
    git clone https://github.com/mddeepaksoni/template.git
    mkdir <repository-name>
    cd <repository-name>
    git init
    cp ../template/*
    ```
2. Setup readme.md file
    ```bash
    mv README.template README.md
    ```
3. Setup gitignore
    ```bash
    cp gitignore/<template>.gitignore .gitignore
    rm -rf gitignore
    ```
4. Setup workflows
    ```bash
    rm .github/workflows/*
    cp gitworkflow/<template>.yml .github/workflows/<workflow>.yml
    rm -rf gitworkflow
    ```
5. Create labels
   Generate Personal Access Tokens via Settings -> Developer Settings -> Personal Access Token
   ```bash
   sh .github/LABEL_TEMPLATE.sh <owner>/<repo> <personal-access-token>
   ```

## Checklist
### Readme
- [ ] Replace `README.md` with `README.template`
- [ ] Remove `README.template`
- [ ] Edit `README.md`

### Git Ignore
- [ ] Copy `gitignore/<template>.gitignore` file to `.gitignore`
- [ ] Remove `gitignore` directory
- [ ] Edit `.gitignore` 

### Git Workflow
- [ ] Copy `gitworkflow/<template>.yml` file to `.github/workflows/<workflow>.yml`
- [ ] Remove `gitworkflow` directory
- [ ] Edit `.github/workflows/<workflow>.yml`

## Contribute
We would be happy to accept pull requests. If you want to work on something, it will be good to talk before hand to make sure nobody else is working on it. You can reach us in [issues](https://github.com/mddeepaksoni/template/issues).

If you want to code, but don't know from where to start, check out issues labelled [help wanted](https://github.com/mddeepaksoni/template/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22+sort%3Areactions-%2B1-desc)

## Authors
* [Deepak Soni](https://www.linkedin.com/in/mddeepaksoni/)