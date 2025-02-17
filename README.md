<a id="readme-top"></a>

<br />
<!-- <div align="center"> -->

<a href="https://dashboard.iith.dev">

![alt text](assets/images/header.png)

</a>
<!-- </div> -->

## IITH Dashboard

IITH Dashboard is an open-source platform designed to streamline campus activities, foster collaboration, and enhance the user experience for the IITH community. With features like **Cabsharing**, **Mess Menu**, **Bus Schedule**, and more, it aims to be a one-stop solution for campus management needs.

  <p align="center">
    <a href="https://dashboard.iith.dev">Access PWA</a>
    ·
    <a href="https://github.com/LambdaIITH/dashboard/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/LambdaIITH/dashboard/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
</p>

![Product Images](assets/images/screenshots.png)

## API Documentation
- **[Cabshare](backend-docs/cabshare.md)**
- **[Lost and Found](backend-docs/lost_found.md)**

## Getting Started

To get a local copy up and running, please follow the steps below

### Prerequisites

- **[Flutter SDK](https://flutter.dev)**
- **[Git SCM](https://git-scm.com/)**
- **[Python](https://python.org)**
- **[Poetry](https://python-poetry.org/)**

### Installation

##### Frontend

1. Navigating to frontend directory from root of the repo
   `cd frontend`
2. Install flutter dependencies
   `flutter pub get`
3. If you are using your own device to run the app make sure its connected, after that run the app.
   `flutter run`

##### Backend

1. Navigate to the backend directory from the root
   `cd backend/backend`
2. Install python dependencies with poetry
   `poetry install`
3. Activate virtual environment
   `poretry shell`
4. Run the FastAPI Server
   `uvicorn main:app --reload`

## Roadmap

- [x] Implement User Authentication
- [x] Add Cabsharing Feature
- [x] Integrate Mess Menu
- [x] Display Bus Schedule
- [ ] **[WIP]** Time Table/Calendar for academic and non-academic events
- [ ] **[WIP]** Lost and Found
- [ ] **[WIP]** Release on dashboard
- [ ] FCM for Notifications
- [ ] Buy and Sell (similar to Lost and Found)

See the [open issues](https://github.com/LambdaIITH/dashboard/issues) for a full list of proposed features (and known issues).

## Contributing

Contributions are what make the open-source community such a remarkable place to learn, inspire, and innovate. We welcome contributions to the **IITH Dashboard**, whether it be bug fixes, new features, improvements to the documentation, or any other enhancements. Anything which enhances the Dashboard are **highly appreciated**

Please read `CONTRIBUTING.md` for more detailed guide on contributing to this project.

## License

Distributed under the MIT License. See `LICENSE.md` for more information.

## Contact

- **Lambda Support**: [support@iith.dev](mailto:support@iith.dev)

## Acknowledgments
Thank you to everyone who played a role in bringing the dashboard to life! We’re deeply grateful to the code contributors, those who suggested new features, reported bugs. Your collective efforts have been invaluable in bringing this project to life.
<a href="https://github.com/LambdaIITH/dashboard/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=LambdaIITH/dashboard" />
</a>
