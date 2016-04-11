/*
 * Copyright (C) 2013-2016 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
*/

namespace UpdatePlugin {

UpdateManager *UpdateManager::m_instance = 0;

UpdateManager *UpdateManager::instance()
{
    if (!m_instance)
        m_instance = new UpdateManager;

    return m_instance;
}

UpdateManager::UpdateManager(QObject *parent):
    QObject(parent)
{
    setUpSystemImage();
    setUpClickUpdateChecker();
    setUpSSOService();
    setUpUdm();
}

UpdateManager::~UpdateManager()
{
}

void UpdateManager::setUpSystemImage()
{

    connect(&m_systemImage,
            SIGNAL(downloadModeChanged()),
            this,
            SIGNAL(downloadModeChanged())
    );
    connect(&m_systemImage,
            SIGNAL(updateAvailableStatus(const bool isAvailable,
                                         const bool downloading,
                                         const QString &availableVersion,
                                         const int &updateSize,
                                         const QString &lastUpdateDate,
                                         const QString &errorReason)),
            this,
            SLOT(siProcessAvailableStatus(const bool isAvailable,
                                          const bool downloading,
                                          const QString &availableVersion,
                                          const int &updateSize,
                                          const QString &lastUpdateDate,
                                          const QString &errorReason))
    );

}


void UpdateManager::setUpClickUpdateChecker()
{
    connect(&m_clickUpChecker,
            SIGNAL(foundClickUpdate(const ClickUpdateMetadata &clickUpdateMetadata)),
            this,
            SLOT(handleClickUpdateMetadataFound(
                    const ClickUpdateMetadata &clickUpdateMetadata))
    );
}


void UpdateManager::setUpSSOService()
{
    connect(&m_ssoService,
            SIGNAL(credentialsFound(const Token &token)),
            this,
            SLOT(handleCredentialsFound(const Token &token))
    );
    connect(&m_ssoService,
            SIGNAL(credentialsNotFound()),
            this,
            SLOT(handleCredentialsFailed())
    );
    connect(&m_ssoService,
            SIGNAL(credentialsDeleted()),
            this,
            SLOT(handleCredentialsFailed())
    );

    m_ssoService.getCredentials();
}


void UpdateManager::setUpUdm()
{

}


bool UpdateManager::online() const
{
    return m_online;
}

void UpdateManager::setOnline(const bool &online)
{
    if (online != m_online) {
        m_online = online;
        Q_EMIT onlineChanged();
    }
}

bool UpdateManager::authenticated() const
{
    return m_authenticated;
}

void UpdateManager::setAuthenticated(const bool &authenticated)
{
    if (authenticated != m_authenticated) {
        m_authenticated = authenticated;
        Q_EMIT authenticatedChanged();
    }

}

bool UpdateManager::haveSufficientPower() const
{
    return m_haveSufficientPower;
}

void UpdateManager::setHaveSufficientPower(const bool &haveSufficientPower)
{
    if (haveSufficientPower != m_haveSufficientPower) {
        m_haveSufficientPower = haveSufficientPower;
        Q_EMIT authenticatedChanged();
    }

}

Ubuntu:DownloadManager::UbuntuDownloadManager UpdateManager::udm() const
{
    return m_udm;
}


int UpdateManager::updatesCount() const
{
    return m_updatesCount;
}

void UpdateManager::setUpdatesCount(const int &count) {
    if (count != m_updatesCount) {
        m_updatesCount = count;
        Q_EMIT updatesCountChanged();
    }
}

int UpdateManager::downloadMode() const
{
    return m_systemImage.downloadMode();
}

void UpdateManager::setDownloadMode(const int &downloadMode)
{
    m_systemImage.setDownloadMode(downloadMode);
}

void UpdateManager::checkForUpdates()
{
    m_systemImage.checkForUpdates();
    m_clickUpChecker.checkForUpdates();
}

void UpdateManager::abortCheckForUpdates()
{
    // TODO: Figure out way to cancel SI check
    m_clickUpChecker.abortCheckForUpdates();
}

bool UpdateManager::clickUpdateInUdm(const ClickUpdateMetadata &clickUpdateMetadata) const
{

}

void UpdateManager::createClickUpdateDownload(const ClickUpdateMetadata &clickUpdateMetadata)
{

}

void UpdateManager::handleCredentialsFound(const Token &token)
{
    m_token = token;

    // Set click update checker's token, and start a check.
    m_clickUpChecker.setToken(token);
    m_clickUpChecker.checkForUpdates();
}

void UpdateManager::handleCredentialsFailed()
{
    m_ssoService.invalidateCredentials();


    // Ask click update checker to stop checking for updates.
    // Revoke the token given to click update checker.
    m_clickUpChecker.abortCheckForUpdates();
    m_clickUpChecker.setToken(null);
}

} // UpdatePlugin
