// ServiceCatalogForm/NotesSection.tsx
// Section 17: Additional Notes - Free-form notes and comments

import React from 'react';
import { useFormContext, Controller } from 'react-hook-form';
import { PencilSquareIcon, InformationCircleIcon } from '@heroicons/react/24/solid';
import { TextArea, Card } from '../../common';

export const NotesSection: React.FC = () => {
  const { control, watch } = useFormContext();
  const notes = watch('notes') || '';
  const charCount = notes.length;
  const maxChars = 10000;

  return (
    <div className="space-y-6">
      {/* Section Header */}
      <div className="flex items-center gap-2 mb-2">
        <PencilSquareIcon className="w-6 h-6 text-gray-500" />
        <h4 className="text-lg font-medium text-gray-900">Additional Notes</h4>
      </div>
      <p className="text-sm text-gray-600">
        Add any additional notes, comments, or information that doesn't fit in other sections.
        This is a free-form field for capturing important details.
      </p>

      {/* Notes Field */}
      <Card className="p-4">
        <Controller
          name="notes"
          control={control}
          render={({ field }) => (
            <TextArea
              {...field}
              label="Notes"
              placeholder="Enter any additional notes, considerations, assumptions, or important information about this service...

Examples of what to include:
• Assumptions made during service design
• Special conditions or exceptions
• Historical context or rationale
• Links to related documentation
• Known limitations or constraints
• Future enhancement ideas"
              rows={12}
              maxLength={maxChars}
              showCharCount
              className="font-mono text-sm"
            />
          )}
        />
        
        {/* Character Count */}
        <div className="flex justify-end mt-2">
          <span className={`text-xs ${charCount > maxChars * 0.9 ? 'text-amber-600' : 'text-gray-500'}`}>
            {charCount.toLocaleString()} / {maxChars.toLocaleString()} characters
          </span>
        </div>
      </Card>

      {/* Tips */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <div className="flex items-start gap-3">
          <InformationCircleIcon className="w-5 h-5 text-gray-500 flex-shrink-0 mt-0.5" />
          <div>
            <h5 className="text-sm font-medium text-gray-800 mb-2">
              💡 What to Include in Notes
            </h5>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
              <ul className="space-y-1">
                <li>• <strong>Assumptions:</strong> What assumptions were made?</li>
                <li>• <strong>Constraints:</strong> Any known limitations?</li>
                <li>• <strong>Rationale:</strong> Why certain decisions were made?</li>
                <li>• <strong>History:</strong> How has this service evolved?</li>
              </ul>
              <ul className="space-y-1">
                <li>• <strong>References:</strong> Links to related docs</li>
                <li>• <strong>Edge Cases:</strong> Special scenarios to consider</li>
                <li>• <strong>Future Plans:</strong> Planned enhancements</li>
                <li>• <strong>Feedback:</strong> Customer feedback received</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Markdown Support Note */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h5 className="text-sm font-medium text-blue-800 mb-2">
          📝 Formatting Tips
        </h5>
        <p className="text-sm text-blue-700 mb-2">
          You can use basic Markdown formatting in notes:
        </p>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs font-mono text-blue-600">
          <div>**bold**</div>
          <div>*italic*</div>
          <div>- bullet list</div>
          <div>1. numbered list</div>
          <div>[link](url)</div>
          <div>`code`</div>
          <div>## heading</div>
          <div>---horizontal rule</div>
        </div>
      </div>

      {/* Service Summary Preview */}
      <div className="bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 rounded-lg p-4">
        <h5 className="text-sm font-medium text-green-800 mb-2">
          ✅ Almost Done!
        </h5>
        <p className="text-sm text-green-700">
          You've reached the final section. Review your entries and click "Save" when ready.
          You can always come back and edit any section later.
        </p>
      </div>
    </div>
  );
};

export default NotesSection;
