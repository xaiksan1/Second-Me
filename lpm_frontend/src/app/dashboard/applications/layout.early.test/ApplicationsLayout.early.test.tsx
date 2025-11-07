import React from 'react'
import { EVENT } from '@/utils/event';
import ApplicationsLayout from '../layout';

// layout.test.tsx
import { act, fireEvent, render, screen } from '@testing-library/react';
import "@testing-library/jest-dom";

// layout.test.tsx
// Mocks for external dependencies
// jest.mock("@/service/info", () => {
//   const actual = jest.requireActual("@/service/info");
//   return {
//     ...actual,
//     getCurrentInfo: jest.mocked(jest.fn()),
//     __esModule: true,
//   };
// });
// jest.mock("@/service/upload", () => {
//   const actual = jest.requireActual("@/service/upload");
//   return {
//     ...actual,
//     connectUpload: jest.mocked(jest.fn()),
//     registerUpload: jest.mocked(jest.fn()),
//     deleteUpload: jest.mocked(jest.fn()),
//     __esModule: true,
//   };
// });
// jest.mock("@/utils/localRegisteredUpload", () => {
//   const actual = jest.requireActual("@/utils/localRegisteredUpload");
//   return {
//     ...actual,
//     updateRegisteredUpload: jest.mocked(jest.fn()),
//     __esModule: true,
//   };
// });

// Mock EVENT
const EVENT = {
  SHOW_REGISTER_MODAL: 'show-register-modal',
} as any;

// Mock NetWorkMemberList
// jest.mock("@/components/upload/NetWorkMemberList", () => ({
//   __esModule: true,
//   default: Mockundefined.render,
// }));

// Mock antd Modal
jest.mock("antd", () => {
  const actual = jest.requireActual("antd");
  return {
    ...actual,
    Modal: ({ open, children, ...props }: any) =>
      open ? (
        <div data-testid="antd-modal" {...props}>
          {children}
        </div>
      ) : null,
  };
});

// Mock RegisterUploadModal (do not mock as per instruction 13)
jest.mock("@/components/upload/RegisterUploadModal", () => {
  const actual = jest.requireActual("@/components/upload/RegisterUploadModal");
  return {
    ...actual,
    __esModule: true,
    default: actual.default,
  };
});

// Mock message from antd
jest.mock("antd/es/message", () => ({
  __esModule: true,
  default: {
    useMessage: () => [ { success: jest.fn(), error: jest.fn(), warning: jest.fn() }, <div /> ],
  },
}));

// Mock hooks except React core
// jest.mock("@/store/useUploadStore", () => ({
//   __esModule: true,
//   default: () => ({
//     addUpload: jest.mocked(jest.fn()),
//     removeUpload: jest.mocked(jest.fn()),
//     total: 1,
//     fetchUploadList: jest.mocked(jest.fn()),
//   }),
// }));
// jest.mock("@/store/useLoadInfoStore", () => ({
//   __esModule: true,
//   default: () => ({
//     fetchLoadInfo: jest.mocked(jest.fn()),
//     setLoadInfo: jest.mocked(jest.fn()),
//     loadInfo: { status: 'unregistered' },
//   }),
// }));
// jest.mock("@/store/useTrainingStore", () => ({
//   __esModule: true,
//   default: () => ({
//     status: 'idle',
//   }),
// }));

// Helper to dispatch custom event
function dispatchShowRegisterModal() {
  act(() => {
    window.dispatchEvent(new Event(EVENT.SHOW_REGISTER_MODAL));
  });
}

describe('ApplicationsLayout() ApplicationsLayout method', () => {
  // Happy Path Tests
  describe('Happy Paths', () => {
    beforeEach(() => {
      jest.clearAllMocks();
    });

    it('renders children and initial layout', () => {
      // This test ensures that the ApplicationsLayout renders its children and the initial layout correctly.
      render(
        <ApplicationsLayout>
          <div data-testid="child-content">Child Content</div>
        </ApplicationsLayout>
      );
      expect(screen.getByTestId('child-content')).toBeInTheDocument();
      expect(screen.queryByTestId('antd-modal')).not.toBeInTheDocument();
    });

    it('shows Register Modal when EVENT.SHOW_REGISTER_MODAL is dispatched', () => {
      // This test checks that the Register Modal appears when the custom event is dispatched.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      expect(screen.getByTestId('antd-modal')).toBeInTheDocument();
      expect(screen.getByText('AI Registration Required')).toBeInTheDocument();
      expect(
        screen.getByText(
          'You need to register (publish) your AI before you can access this feature.'
        )
      ).toBeInTheDocument();
    });

    it('closes Register Modal when Cancel button is clicked', () => {
      // This test ensures that clicking the Cancel button closes the Register Modal.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      const cancelBtn = screen.getByText('Cancel');
      fireEvent.click(cancelBtn);
      expect(screen.queryByTestId('antd-modal')).not.toBeInTheDocument();
    });

    it('opens Publish Modal when Go to Register is clicked', () => {
      // This test ensures that clicking Go to Register closes the Register Modal and opens the Publish Modal.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      const goToRegisterBtn = screen.getByText('Go to Register');
      fireEvent.click(goToRegisterBtn);
      // Register Modal should close
      expect(screen.queryByText('AI Registration Required')).not.toBeInTheDocument();
      // Publish Modal should open (RegisterUploadModal)
      // The RegisterUploadModal renders a Modal with title "Join the Second Me Network"
      expect(screen.getByText('Join the Second Me Network')).toBeInTheDocument();
    });

    it('closes Publish Modal when RegisterUploadModal onClose is triggered', () => {
      // This test ensures that the Publish Modal closes when RegisterUploadModal's onClose is called.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      fireEvent.click(screen.getByText('Go to Register'));
      // Simulate onClose by clicking the close button in Modal (if present)
      // Since Modal is mocked, we can simulate onCancel
      const modal = screen.getByText('Join the Second Me Network').closest('[data-testid="antd-modal"]');
      if (modal) {
        fireEvent.click(modal);
      }
      // The Publish Modal should close
      expect(screen.queryByText('Join the Second Me Network')).not.toBeInTheDocument();
    });

    it('RegisterUploadModal displays network member list', () => {
      // This test ensures that the RegisterUploadModal displays the mocked network member list.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      fireEvent.click(screen.getByText('Go to Register'));
      expect(screen.getByTestId('network-member-list')).toBeInTheDocument();
      expect(screen.getByText('Mock Network Member List')).toBeInTheDocument();
    });

    it('RegisterUploadModal displays correct title and description', () => {
      // This test ensures that the RegisterUploadModal displays the correct title and description.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      fireEvent.click(screen.getByText('Go to Register'));
      expect(screen.getByText('Join the Second Me Network')).toBeInTheDocument();
      expect(
        screen.getByText(
          /Connect your Second Me to the global network to interact with other digital minds/i
        )
      ).toBeInTheDocument();
    });
  });

  // Edge Case Tests
  describe('Edge Cases', () => {
    beforeEach(() => {
      jest.clearAllMocks();
    });

    it('does not show Register Modal if EVENT.SHOW_REGISTER_MODAL is not dispatched', () => {
      // This test ensures that the Register Modal does not appear unless the event is dispatched.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      expect(screen.queryByText('AI Registration Required')).not.toBeInTheDocument();
    });

    it('handles multiple EVENT.SHOW_REGISTER_MODAL events gracefully', () => {
      // This test ensures that multiple event dispatches do not break the modal logic.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      expect(screen.getByText('AI Registration Required')).toBeInTheDocument();
      // Dispatch again
      dispatchShowRegisterModal();
      expect(screen.getByText('AI Registration Required')).toBeInTheDocument();
    });

    it('does not crash if children is an empty fragment', () => {
      // This test ensures that ApplicationsLayout works with empty children.
      render(<ApplicationsLayout>{<></>}</ApplicationsLayout>);
      expect(screen.queryByTestId('antd-modal')).not.toBeInTheDocument();
    });

    it('does not crash if children is a string', () => {
      // This test ensures that ApplicationsLayout works with string children.
      render(<ApplicationsLayout>{'Just a string child'}</ApplicationsLayout>);
      expect(screen.getByText('Just a string child')).toBeInTheDocument();
    });

    it('removes event listener on unmount', () => {
      // This test ensures that the event listener is removed when the component unmounts.
      const { unmount } = render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      unmount();
      // After unmount, dispatching the event should not show the modal
      dispatchShowRegisterModal();
      expect(screen.queryByText('AI Registration Required')).not.toBeInTheDocument();
    });

    it('does not open Publish Modal if Go to Register is not clicked', () => {
      // This test ensures that the Publish Modal does not open unless Go to Register is clicked.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      expect(screen.queryByText('Join the Second Me Network')).not.toBeInTheDocument();
    });

    it('handles rapid open/close of Register Modal', () => {
      // This test ensures that rapid open/close of the Register Modal does not break the state.
      render(
        <ApplicationsLayout>
          <div>Test</div>
        </ApplicationsLayout>
      );
      dispatchShowRegisterModal();
      fireEvent.click(screen.getByText('Cancel'));
      dispatchShowRegisterModal();
      expect(screen.getByText('AI Registration Required')).toBeInTheDocument();
    });
  });
});